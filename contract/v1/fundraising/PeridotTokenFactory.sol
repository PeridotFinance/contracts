// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import '@openzeppelin/contracts/utils/Create2.sol';
import '../library/PeridotMiniNFTHelper.sol';
import '../library/PeridotFFTHelper.sol';
import '../interface/IPeridotTokenFactory.sol';
import '../interface/IPeridotSwap.sol';

contract PeridotTokenFactory is IPeridotTokenFactory {
  address private _owner;
  address private _PeridotGovernor;
  address public PeridotSwap;
  address private _PeridotVault;
  address private _PeridotPFVault; //poolfundingvault
  address public pendingVault;
  address public pendingPFVault;

  mapping(address => address) public projectToMiniNFT;
  mapping(address => address) public projectToFFT;
  
  event CollectionPairCreated(
        address indexed projectAddress,
        address indexed newMiniNFTContract,
        address indexed newFFTContract
  );

  constructor(
    address daoAddress,
    address swapAddress,
    address vaultAddress,
    address PFvaultAddress
  ) {
    _owner = msg.sender;
    _PeridotGovernor = daoAddress;
    _PeridotVault = vaultAddress;
    _PeridotPFVault = PFvaultAddress;
    PeridotSwap = swapAddress;

    pendingVault = _PeridotVault;
    pendingPFVault = _PeridotPFVault;
  }

  modifier onlyFactoryOwner() {
    require(msg.sender == _owner, 'Peridot: invalid caller');
    _;
  }

  modifier onlyDao() {
    require(msg.sender == _PeridotGovernor, 'Peridot: caller is not dao');
    _;
  }

  function createCollectionPair(
    address projectAddress,
    bytes32 salt,
    string memory miniNFTBaseUri,
    string memory name,
    string memory symbol
  ) external onlyFactoryOwner returns (address, address) {
    require(
      projectToMiniNFT[projectAddress] == address(0) &&
        projectToFFT[projectAddress] == address(0),
      'Already exist.'
    );

    address newMiniNFTContract = Create2.deploy(
      0,
      salt,
      PeridotMiniNFTHelper.getBytecode(miniNFTBaseUri)
    );

    require(newMiniNFTContract != address(0), 'Peridot: deploy MiniNFT Failed');

    address newFFTContract = Create2.deploy(
      0,
      salt,
      PeridotFFTHelper.getBytecode(name, symbol)
    );

    require(newFFTContract != address(0), 'Peridot: deploy FFT Failed');

    projectToMiniNFT[projectAddress] = newMiniNFTContract;
    projectToFFT[projectAddress] = newFFTContract;

    require(
      IPeridotSwap(PeridotSwap).updatePoolRelation(
        newMiniNFTContract,
        newFFTContract,
        projectAddress
      )
    );

    emit CollectionPairCreated(projectAddress, newMiniNFTContract, newFFTContract);

    return (newMiniNFTContract, newFFTContract);
  }

  function updateDao(address daoAddress) external onlyDao returns (bool) {
    _PeridotGovernor = daoAddress;
    return true;
  }

  function signDaoReq() external onlyFactoryOwner returns (bool) {
    _PeridotVault = pendingVault;
    _PeridotPFVault = pendingPFVault;

    return true;
  }

  function updateVault(address pendingVault_) external onlyDao returns (bool) {
    pendingVault = pendingVault_;
    return true;
  }

  function updatePFVault(address pendingPFVault_)
    external
    onlyDao
    returns (bool)
  {
    pendingPFVault = pendingPFVault_;
    return true;
  }

  function getowner() external view override returns (address) {
    return _owner;
  }

  function getDAOAddress() external view override returns (address) {
    return _PeridotGovernor;
  }

  function getSwapAddress() external view override returns (address) {
    return PeridotSwap;
  }

  function getVaultAddress() external view override returns (address) {
    return _PeridotVault;
  }

  function getPoolFundingVaultAddress()
    external
    view
    override
    returns (address)
  {
    return _PeridotPFVault;
  }
}
