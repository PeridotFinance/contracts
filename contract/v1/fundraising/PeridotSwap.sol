// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "../witnet-solidity-bridge/contracts/interfaces/IWitnetRandomness.sol";
import "../interface/IPeridotMiniNFT.sol";
import "../interface/IPeridotFFT.sol";
import "../interface/IPeridotSwap.sol";
import "../interface/IPeridotTokenFactory.sol";


contract PeridotSwap is ERC721Holder, ERC1155Holder, Ownable, IPeridotSwap, ReentrancyGuard {
    IWitnetRandomness public witnetRandomness;

    uint256 public swapRate = 1E21;
    uint256 public fftTax = 3E18;
    uint256 public nftTax = 3;

    address public tokenFactory;
    address public requestIdRecipient;

    mapping(uint256 => RandomnessRequest) public randomnessRequests;
    mapping(address => uint256[]) public NFTIds;
    mapping(address => address) public NFTtoMiniNFT;
    mapping(address => address) public miniNFTtoFFT;
    mapping(address => uint256) public latestRequestById;

    event RandomnessRequested(uint256 requestId, address requestedBy, uint256 requestBlock);
    event RandomnessFulfilled(uint256 requestId, uint32 randomNumber, address fulfilledBy);
    event RandomnessRequestCancelled(uint256 requestId);
    event RandomnessReRequested(uint256 oldRequestId, uint256 newRequestId);

    error RandomnessAlreadyFulfilled(uint256 requestId);
    error RequestNotYetExpired(uint256 blocksSinceRequest);
    error RequestAlreadyCompleted(uint256 requestId);

    struct RandomnessRequest {
    address sender;
    address nft;
    uint256 requestBlock;
    uint32 nonce;
    bool completed;
    uint32 randomNumber;
    }

    modifier onlyDAO() {
        address dao = IPeridotTokenFactory(tokenFactory).getDAOAddress();
        require(msg.sender == dao, "Peridot: caller is not Peridot DAO");
        _;
    }

    modifier onlyFactoryOrOwner() {
        require(msg.sender == tokenFactory || msg.sender == owner(), "Invalid Caller");
        _;
    }

    constructor(address _witnetRandomness) {
        witnetRandomness = IWitnetRandomness(_witnetRandomness);
    }

    function updatePoolRelation(address miniNFT, address FFT, address NFT) external onlyFactoryOrOwner returns (bool) {
        miniNFTtoFFT[miniNFT] = FFT;
        NFTtoMiniNFT[NFT] = miniNFT;
        emit UpdatePoolRelation(msg.sender, miniNFT, FFT, NFT);
        return true;
    }

     function poolClaim(address miniNFTContract, uint256 tokenID)
    external
    virtual
    override
    returns (bool)
  {
    require(
      miniNFTtoFFT[miniNFTContract] != address(0),
      'swap: invalid contract'
    );
    require(IPeridotMiniNFT(miniNFTContract).claimBlindBox(tokenID) > 0);

    emit PoolClaim(msg.sender, miniNFTContract, tokenID);
    return true;
  }

  function swapMiniNFTtoFFT(
    address miniNFTContract,
    uint256 tokenID,
    uint256 amount
  ) external virtual override nonReentrant returns (bool) {
    require(
      miniNFTtoFFT[miniNFTContract] != address(0),
      'swap: invalid contract'
    );

    uint256 miniNFTBalance = IERC1155(miniNFTContract).balanceOf(
      msg.sender,
      tokenID
    );
    require(miniNFTBalance >= amount, 'swap: balance insufficient');

    IERC1155(miniNFTContract).safeTransferFrom(
      msg.sender,
      address(this),
      tokenID,
      amount,
      ''
    );

    require(
      IPeridotFFT(miniNFTtoFFT[miniNFTContract]).swapmint(
        amount * swapRate,
        msg.sender
      )
    );

    emit SwapMiniNFTtoFFT(msg.sender, miniNFTContract, tokenID, amount);
    return true;
  }

  function swapMiniNFTtoNFT(address NFTContract) external payable nonReentrant returns (bool) {
    require(NFTtoMiniNFT[NFTContract] != address(0), "swap: invalid contract");
    require(NFTIds[NFTContract].length > 0, "swap: no NFT left");
    uint256 requestId = witnetRandomness.randomize{value: msg.value}();
    RandomnessRequest storage request = randomnessRequests[requestId];
    request.sender = msg.sender;
    request.nft = NFTContract;
    request.requestBlock = block.number;
    request.nonce = 0;
    request.completed = false;
    latestRequestById[msg.sender] = requestId;
    emit RandomnessRequested(requestId, msg.sender, block.number);
    return true;
  }


  function processRandomness() external {
    uint256 requestId = latestRequestById[msg.sender];
    require(requestId != 0, "No randomness request found for caller");

    RandomnessRequest storage request = randomnessRequests[requestId];
    
    require(witnetRandomness.isRandomized(request.requestBlock), "Randomness not yet available");
    
    bytes32 randomness = witnetRandomness.getRandomnessAfter(request.requestBlock);
    uint32 randomNumber = witnetRandomness.random(uint32(0xFFFFFFFF), request.nonce, randomness);

    request.nonce++;
    request.completed = true;
    request.randomNumber = randomNumber;
    address sender = request.sender;
    address NFTContract = request.nft;

    address miniNFTContract = NFTtoMiniNFT[NFTContract];
    IERC1155(miniNFTContract).safeTransferFrom(
      sender,
      address(this),
      0,
      1000,
      ''
    );
    // Burn mini-NFTs from the sender's balance
    IPeridotMiniNFT(miniNFTContract).burn(1000);

    // Transfer the fee in mini-NFTs to the vault
    uint256 feeAmount = nftTax; // Assuming `nftTax` is the fee in mini-NFT units
    IERC1155(miniNFTContract).safeTransferFrom(sender, IPeridotTokenFactory(tokenFactory).getVaultAddress(), 0, feeAmount, "");

    // Select and transfer the NFT to the sender based on the random number
    uint256 NFTNumber = NFTIds[NFTContract].length;
    require(NFTNumber > 0, "swap: no NFT left");
    uint256 NFTIndex = uint256(randomNumber) % NFTNumber;
    uint256 NFTID = NFTIds[NFTContract][NFTIndex];

    // Remove the NFT from the list (swap logic)
    NFTIds[NFTContract][NFTIndex] = NFTIds[NFTContract][NFTNumber - 1];
    NFTIds[NFTContract].pop();

    // Transfer the selected NFT to the sender
    IERC721(NFTContract).safeTransferFrom(address(this), sender, NFTID);

    // Emitting event for swap completion
    emit SwapMiniNFTtoNFT(sender, NFTContract, NFTID);
    emit RandomnessFulfilled(requestId, randomNumber, request.sender);
}


function swapFFTtoMiniNFT(address miniNFTContract, uint256 miniNFTAmount)
    external
    virtual
    override
    nonReentrant
    returns (bool)
  {
    require(
      miniNFTtoFFT[miniNFTContract] != address(0),
      'swap: invalid contract'
    );
    require(
      IERC1155(miniNFTContract).balanceOf(address(this), 0) >= miniNFTAmount,
      'swap:insufficient miniNFT in pool'
    );
    uint256 FFTamount = miniNFTAmount * swapRate;
    uint256 taxfee = miniNFTAmount * fftTax;

    require(
      IPeridotFFT(miniNFTtoFFT[miniNFTContract]).burnFrom(msg.sender, FFTamount)
    );

    require(
      IPeridotFFT(miniNFTtoFFT[miniNFTContract]).transferFrom(
        msg.sender,
        IPeridotTokenFactory(tokenFactory).getVaultAddress(),
        taxfee
      )
    );
    IERC1155(miniNFTContract).safeTransferFrom(
      address(this),
      msg.sender,
      0,
      miniNFTAmount,
      ''
    );

    emit SwapFFTtoMiniNFT(msg.sender, miniNFTContract, miniNFTAmount);
    return true;
  }

  function swapNFTtoMiniNFT(
    address NFTContract,
    address fromOwner,
    uint256 tokenId
  ) external virtual override onlyDAO nonReentrant returns (bool) {
    address miniNFTContract = NFTtoMiniNFT[NFTContract];

    require(miniNFTContract != address(0), 'swap: invalid contract');

    IERC721(NFTContract).safeTransferFrom(fromOwner, address(this), tokenId);

    require(IPeridotMiniNFT(miniNFTContract).swapmint(1000, fromOwner));

    return true;
  }

  function withdrawERC20(address project, uint256 amount)
    external
    onlyDAO
    returns (bool)
  {
    require(
      IERC20(project).transfer(msg.sender, amount),
      'swap: withdraw failed'
    );
    return true;
  }

  function withdrawERC721(address airdropContract, uint256 tokenId)
    external
    onlyDAO
    returns (bool)
  {
    require(
      NFTtoMiniNFT[airdropContract] == address(0),
      'swap: cannot withdraw ProjectNFT'
    );

    IERC721(airdropContract).safeTransferFrom(
      address(this),
      msg.sender,
      tokenId
    );

    return true;
  }

  function withdrawERC1155(
    address airdropContract,
    uint256 tokenId,
    uint256 amount
  ) external onlyDAO returns (bool) {
    require(
      miniNFTtoFFT[airdropContract] == address(0),
      'swap: cannot withdraw ProjectNFT'
    );

    IERC1155(airdropContract).safeTransferFrom(
      address(this),
      msg.sender,
      tokenId,
      amount,
      ''
    );

    return true;
  }

  function updateFactory(address factory_) external onlyOwner returns (bool) {
    require(tokenFactory == address(0), 'swap: factory has been set');
    require(factory_ != address(0), 'swap: factory can not be 0 address');

    tokenFactory = factory_;

    emit UpdateFactory(factory_);
    return true;
  }

  function updateTax(uint256 fftTax_, uint256 nftTax_)
    external
    onlyDAO
    returns (bool)
  {
    fftTax = fftTax_;
    nftTax = nftTax_;

    emit UpdateTax(fftTax_, nftTax_);
    return true;
  }

  function onERC721Received(
    address operator,
    address from,
    uint256 tokenId,
    bytes memory data
) public override(ERC721Holder) returns (bytes4) {
    NFTIds[msg.sender].push(tokenId);
    return this.onERC721Received.selector;
}


  function numberOfNFT(address NFTContract) external view returns (uint256) {
    return NFTIds[NFTContract].length;
  }
  
  function cancelRandomnessRequest(uint256 requestId) external {
        RandomnessRequest storage request = randomnessRequests[requestId];
        if (request.completed) {
          revert RandomnessAlreadyFulfilled({requestId: requestId});
        }

        request.completed = true;

        emit RandomnessRequestCancelled(requestId);
  }

  function checkAndReRequestRandomness(uint256 requestId) external payable{
    RandomnessRequest storage request = randomnessRequests[requestId];
    uint256 blocksSinceRequest = block.number - request.requestBlock;

    uint256 TIMEOUT_BLOCKS = 100;  // Example timeout threshold

    if (blocksSinceRequest <= TIMEOUT_BLOCKS) {
        revert RequestNotYetExpired({blocksSinceRequest: blocksSinceRequest});
    }
    if (request.completed) {
        revert RequestAlreadyCompleted({requestId: requestId});
    }

    uint256 newRequestId = witnetRandomness.randomize{value: msg.value}();

    RandomnessRequest storage newRequest = randomnessRequests[newRequestId];
    newRequest.sender = request.sender;
    newRequest.nft = request.nft;
    newRequest.requestBlock = block.number;
    newRequest.nonce = 0;
    newRequest.completed = false;

    request.completed = true;

    emit RandomnessReRequested(requestId, newRequestId);
  }

  function getLatestRequestId(address user) external view onlyDAO returns  (uint256) {
      return latestRequestById[user];
    }

  receive () external payable {}

}
