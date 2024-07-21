# Create Collection

createCollectionPair function -> creates MiniNFT & FFT (& Returns address)

# Start Auction

set selling price
call "startNewRound" function
participants call "mintBlindbox"

# End Auction

Owner calls "updateRoundSucceed" to end auction
Participants call 'claimBlindBox' to burn their BlindBox for ERC1155

# Updating Uri

Uri gets updated with the tokenId and then the Uri. 0 is the Mini NFT and 1 (2, etc) are for the BlindBox.

# After Auction

-> NFT gets bought
-> On MetaSwap -> swapNFTtoMiniNFT
(-> swapMiniNFTtoFFT)
-> Deposit MiniNFT/FFT to Vault/Address

---

# TokenVesting

1. Set a Vesting Schedule
   setVestingSchedule(beneficiary, cliffDuration, duration, interval, isRevocable);

2. Grant Tokens
   addGrant(beneficiary, vestingAmount, startDay, duration, cliffDuration, interval, isRevocable);
   or
   addGrantFromToday(beneficiary, vestingAmount, duration, cliffDuration, interval, isRevocable);

3. Claim Vested Tokens
   claimVestingTokens(beneficiary);

beneficiary:

Type: address
Description: The Ethereum address of the account to which the tokens will be granted. This is the recipient of the vesting tokens.

vestingAmount:

Type: uint256
Description: The total number of tokens that are subject to vesting. This is the amount of tokens that will gradually become available to the beneficiary according to the vesting schedule.

startDay:

Type: uint32
Description: The start day of the vesting schedule, specified in days since the UNIX epoch (January 1, 1970). This marks the beginning of the vesting period.

duration:

Type: uint32
Description: The total duration of the vesting schedule, in days. This is the period over which the tokens will vest, starting from the startDay.

cliffDuration:

Type: uint32
Description: The duration of the cliff period, in days. The cliff is a period at the beginning of the vesting schedule during which no tokens vest. After the cliff period ends, tokens will begin to vest according to the schedule.

interval:

Type: uint32
Description: The number of days between vesting events. This specifies how frequently tokens vest after the cliff period. For example, if the interval is 30 days, tokens will vest every 30 days.

isRevocable:

Type: bool
Description: A boolean flag indicating whether the grant can be revoked. If true, the vesting grant can be revoked by the owner (typically in cases where the tokens were given as a gift). If false, the grant cannot be revoked (typically in cases where tokens were purchased).

Example:

addGrant(
0x1234567890abcdef1234567890abcdef12345678, // beneficiary address
1000 \* 10\*\*18, // vestingAmount (assuming 18 decimal places for the token)
18500, // startDay (some day in the future/past in UNIX epoch days)
365, // duration (1 year)
90, // cliffDuration (3 months)
30, // interval (monthly vesting)
true // isRevocable
);

-The beneficiary is 0x1234567890abcdef1234567890abcdef12345678.
-vestingAmount is 1000 tokens (assuming the token has 18 decimal places).
-startDay is specified as 18500 days since the UNIX epoch.
-The vesting schedule lasts for 1 year (duration of 365 days).
-There is a 3-month cliff (cliffDuration of 90 days).
-Tokens vest monthly (interval of 30 days).
-The grant is revocable (isRevocable is true).
