pragma solidity =0.5.16;
import "./FPTData.sol";
import "../ERC20/Erc20BaseProxy.sol";

/**
 * @title FPTCoin is finnexus collateral Pool token, implement ERC20 interface.
 * @dev ERC20 token. Its inside value is collatral pool net worth.
 *
 */
contract TokenConverterProxy is FPTData,Erc20BaseProxy {
    constructor (address implementation_,address minePoolAddr,string memory tokenName) Erc20BaseProxy(implementation_) public{
        _FnxMinePool = IFNXMinePool(minePoolAddr);
        name = tokenName;
    }
    
    /**
     * @dev Retrieve user's start time for burning. 
     *  user user's account.
     */ 
    function getUserBurnTimeLimite(address /*user*/) public view returns (uint256){
        delegateToViewAndReturn();
    }

}
