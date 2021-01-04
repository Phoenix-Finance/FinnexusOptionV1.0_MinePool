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
    
    function setOptionColPool(address _optionColPool) public  {
        delegateAndReturn();
    }
    
    function setMinePool( address _minePool) public  {
       delegateAndReturn();
    }
    
    function setFnxToken(address _fnxToken) public  {
        delegateAndReturn();
    }
   
    function setFptbToken(address _ftpbToken) public  {
        delegateAndReturn();
    }
    
    function setTotalAirdropFnx(uint256 _totalAirdropFnx) public  {
        delegateAndReturn();
    }

    function setFnxPerPerson(uint256 _fnxPerPerson)  public  {
        delegateAndReturn();
    }
    
    /**
     * @dev getting back the left mine token
     * @param reciever the reciever for getting back mine token
     */
    function getbackLeftFnx(address reciever)  public  {
        delegateAndReturn();
    }  

    /**
     * @dev Retrieve user's locked balance. 
     * @param account user's account.
     */ 
    function balanceOfAirdrop(address account) public view returns (uint256) {
        delegateToViewAndReturn();   
    }


    function addWhiteList(address account) external {
        airDropWhiteList[account] = fnxPerPerson;
    }
    
    
    function claim() external {
        delegateAndReturn();
    }
    
}
