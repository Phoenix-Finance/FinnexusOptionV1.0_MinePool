pragma solidity =0.5.16;
import "./AirdropVaultData.sol";
import "../Proxy/baseProxy.sol";

/**
 * @title FPTCoin is finnexus collateral Pool token, implement ERC20 interface.
 * @dev ERC20 token. Its inside value is collatral pool net worth.
 *
 */
contract AirDropVaultProxy is AirDropVaultData,baseProxy {
    
    constructor (address implementation_) baseProxy(implementation_) public{
    }
    
    function setOptionColPool(address /*_optionColPool*/) public  {
        delegateAndReturn();
    }
    
    function setMinePool( address /*_minePool*/) public  {
       delegateAndReturn();
    }
    
    function setFnxToken(address /*_fnxToken*/) public  {
        delegateAndReturn();
    }
   
    function setFptbToken(address /*_ftpbToken*/) public  {
        delegateAndReturn();
    }
    

    function getbackLeftFnx(address /*reciever*/)  public  {
        delegateAndReturn();
    }  


    function balanceOfAirdrop(address /*account*/) public view returns (uint256) {
        delegateToViewAndReturn();   
    }


    function addWhiteList(address/*_account*/,uint256 /*_fnxnumber*/) public {
        delegateAndReturn();
    }
    
    
    function claim() external {
        delegateAndReturn();
    }
    
}
