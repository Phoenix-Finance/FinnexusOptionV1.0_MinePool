pragma solidity =0.5.16;
import "../Proxy/newBaseProxy.sol";

/**
 * @title FNX period mine pool.
 * @dev A smart-contract which distribute some mine coins when user stake FPT-A and FPT-B coins.
 *
 */
contract fixedMinePoolProxy is newBaseProxy {
    /**
    * @dev constructor.
    * @param FPTA FPT-A coin's address,staking coin
    * @param FPTB FPT-B coin's address,staking coin
    * @param USDC USDC coin's address,premium coin
    * @param startTime the start time when this mine pool begin.
    */
    constructor (address implementation_,address FPTA,address FPTB,address USDC,uint256 startTime) newBaseProxy(implementation_) public{
        (bool success,) = implementation_.delegatecall(abi.encodeWithSignature(
                "setAddresses(address,address,address,uint256)",
                FPTA,
                FPTB,
                USDC,
                startTime));
        require(success);
    }
        /**
     * @dev default function for foundation input miner coins.
     */
    function()external payable{

    }
        /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        delegateToViewAndReturn(); 
    }
    /**
     * @dev Returns true if the caller is the current owner.
     */
    function isOwner() public view returns (bool) {
        delegateToViewAndReturn(); 
    }
    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public {
        delegateAndReturn();
    }
    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address /*newOwner*/) public {
        delegateAndReturn();
    }
    function setHalt(bool /*halt*/) public  {
        delegateAndReturn();
    }
     function addWhiteList(address /*addAddress*/)public{
        delegateAndReturn();
    }
    /**
     * @dev Implementation of revoke an invalid address from the whitelist.
     *  removeAddress revoked address.
     */
    function removeWhiteList(address /*removeAddress*/)public returns (bool){
        delegateAndReturn();
    }
    /**
     * @dev Implementation of getting the eligible whitelist.
     */
    function getWhiteList()public view returns (address[] memory){
        delegateToViewAndReturn();
    }
    /**
     * @dev Implementation of testing whether the input address is eligible.
     *  tmpAddress input address for testing.
     */    
    function isEligibleAddress(address /*tmpAddress*/) public view returns (bool){
        delegateToViewAndReturn();
    }
    function setOperator(uint256 /*index*/,address /*addAddress*/)public{
        delegateAndReturn();
    }
    function getOperator(uint256 /*index*/)public view returns (address) {
        delegateToViewAndReturn(); 
    }
    function getFPTAAddress()public view returns (address) {
        delegateToViewAndReturn(); 
    }
    function getFPTBAddress()public view returns (address) {
        delegateToViewAndReturn(); 
    }
    function getStartTime()public view returns (uint256) {
        delegateToViewAndReturn(); 
    }
    function getCurrentPeriodID()public view returns (uint256) {
        delegateToViewAndReturn(); 
    }
    function getUserFPTABalance(address /*account*/)public view returns (uint256) {
        delegateToViewAndReturn(); 
    }
    function getUserFPTBBalance(address /*account*/)public view returns (uint256) {
        delegateToViewAndReturn(); 
    }
    function getUserMaxPeriodId(address /*account*/)public view returns (uint256) {
        delegateToViewAndReturn(); 
    }
    function getUserExpired(address /*account*/)public view returns (uint256) {
        delegateToViewAndReturn(); 
    }
    function getUserCurrentAPY(address /*account*/,address /*mineCoin*/)public view returns (uint256){
        delegateToViewAndReturn(); 
    }
    /**
     * @dev foundation redeem out mine coins.
     *  mineCoin mineCoin address
     *  amount redeem amount.
     */
    function redeemOut(address /*mineCoin*/,uint256 /*amount*/)public{
        delegateAndReturn();
    }
    /**
     * @dev retrieve total distributed mine coins.
     *  mineCoin mineCoin address
     */
    function getTotalMined(address /*mineCoin*/)public view returns(uint256){
        delegateToViewAndReturn(); 
    }
    /**
     * @dev retrieve minecoin distributed informations.
     *  mineCoin mineCoin address
     * @return distributed amount and distributed time interval.
     */
    function getMineInfo(address /*mineCoin*/)public view returns(uint256,uint256){
        delegateToViewAndReturn(); 
    }
    /**
     * @dev retrieve user's mine balance.
     *  account user's account
     *  mineCoin mineCoin address
     */
    function getMinerBalance(address /*account*/,address /*mineCoin*/)public view returns(uint256){
        delegateToViewAndReturn(); 
    }
    /**
     * @dev Set mineCoin mine info, only foundation owner can invoked.
     *  mineCoin mineCoin address
     *  _mineAmount mineCoin distributed amount
     *  _mineInterval mineCoin distributied time interval
     */
    function setMineCoinInfo(address /*mineCoin*/,uint256 /*_mineAmount*/,uint256 /*_mineInterval*/)public {
        delegateAndReturn();
    }

    /**
     * @dev user redeem mine rewards.
     *  mineCoin mine coin address
     *  amount redeem amount.
     */
    function redeemMinerCoin(address /*mineCoin*/,uint256 /*amount*/)public{
        delegateAndReturn();
    }
    function getMineWeightRatio()public view returns (uint256) {
        delegateToViewAndReturn(); 
    }
    function getTotalDistribution() public view returns (uint256){
        delegateToViewAndReturn(); 
    }
    function getPeriodIndex(uint256 /*_time*/) public view returns (uint256) {
        delegateToViewAndReturn(); 
    }
    function getPeriodFinishTime(uint256 /*periodID*/)public view returns (uint256) {
        delegateToViewAndReturn(); 
    }
    function stakeFPTA(uint256 /*amount*/)public {
        delegateAndReturn();
    }
    function lockAirDrop(address /*user*/,uint256 /*ftp_b_amount*/) external{
        delegateAndReturn();
    }
    function stakeFPTB(uint256 /*amount*/,uint256 /*lockedPeriod*/)public{
        delegateAndReturn();
    }
    function unstakeFPTA(uint256 /*amount*/)public {
        delegateAndReturn();
    }
    function unstakeFPTB(uint256 /*amount*/)public{
        delegateAndReturn();
    }
    function changeFPTBLockedPeriod(uint256 /*lockedPeriod*/)public{
        delegateAndReturn();
    }

       /**
     * @dev retrieve total distributed premium coins.
     */
    function getTotalPremium()public view returns(uint256){
        delegateToViewAndReturn(); 
    }

    /**
     * @dev user redeem mine rewards.
     *  amount redeem amount.
     */
    function redeemPremium(uint256 /*amount*/)public{
        delegateAndReturn();
    }

    function getUserLatestPremium(address /*account*/)public view returns(uint256){
        delegateToViewAndReturn(); 
    }
 

    function distributePremium(uint256 /*periodID*/,uint256 /*amount*/)public {
        delegateAndReturn();
    }
        /**
     * @dev Emitted when `account` stake `amount` FPT-A coin.
     */
    event StakeFPTA(address indexed account,uint256 amount);
    /**
     * @dev Emitted when `from` airdrop `recieptor` `amount` FPT-B coin.
     */
    event LockAirDrop(address indexed from,address indexed recieptor,uint256 amount);
    /**
     * @dev Emitted when `account` stake `amount` FPT-B coin and locked `lockedPeriod` periods.
     */
    event StakeFPTB(address indexed account,uint256 amount,uint256 lockedPeriod);
    /**
     * @dev Emitted when `account` unstake `amount` FPT-A coin.
     */
    event UnstakeFPTA(address indexed account,uint256 amount);
    /**
     * @dev Emitted when `account` unstake `amount` FPT-B coin.
     */
    event UnstakeFPTB(address indexed account,uint256 amount);
    /**
     * @dev Emitted when `account` change `lockedPeriod` locked periods for FPT-B coin.
     */
    event ChangeLockedPeriod(address indexed account,uint256 lockedPeriod);
    /**
     * @dev Emitted when owner `account` distribute `amount` premium in `periodID` period.
     */
    event DistributePremium(address indexed account,uint256 indexed periodID,uint256 amount);
    /**
     * @dev Emitted when `account` redeem `amount` premium.
     */
    event RedeemPremium(address indexed account,uint256 amount);

    /**
     * @dev Emitted when `account` redeem `value` mineCoins.
     */
    event RedeemMineCoin(address indexed account, address indexed mineCoin, uint256 value);

}