pragma solidity =0.5.16;
import "./TokenConverterData.sol";
import "../Proxy/baseProxy.sol";

/**
 * @title FPTCoin is finnexus collateral Pool token, implement ERC20 interface.
 * @dev ERC20 token. Its inside value is collatral pool net worth.
 *
 */
contract TokenConverterProxy is TokenConverterData,baseProxy {
    
    constructor (address implementation_) baseProxy(implementation_) public{
    }
    
    function getbackLeftFnx(address reciever)  public {
        delegateAndReturn();
    }
    
   function setParameter(address _cfnxAddress,address _fnxAddress,uint256 _timeSpan,uint256 _dispatchTimes,uint256 _txNum) public  {
        delegateAndReturn();
   }
   
   function lockedBalanceOf(address account) public view returns (uint256){
         delegateToViewAndReturn();     
   }
   
   function inputCfnxForInstallmentPay(uint256 amount) public {
         delegateAndReturn();     
   }
   
   function claimFnxExpiredReward() public {
        delegateAndReturn(); 
   }
    
}
