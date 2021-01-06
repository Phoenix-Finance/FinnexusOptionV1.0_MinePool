pragma solidity =0.5.16;
import "../Proxy/newBaseProxy.sol";

/**
 * @title FPTCoin is finnexus collateral Pool token, implement ERC20 interface.
 * @dev ERC20 token. Its inside value is collatral pool net worth.
 *
 */
contract fixedMinePoolProxy is newBaseProxy {
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
    function setFPTAAddress(address /*FPTA*/) public {
        delegateAndReturn();
    }
    function setFPTBAddress(address /*FPTB*/)public {
        delegateAndReturn();
    }
    function getFPTAAddress()public view returns (address) {
        delegateToViewAndReturn(); 
    }
    function getFPTBAddress()public view returns (address) {
        delegateToViewAndReturn(); 
    }
    function setStartTime(uint256 /*startTime*/) public {
        delegateAndReturn();
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
}