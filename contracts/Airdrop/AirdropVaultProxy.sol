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
    
    function balanceOfAirdrop(address /*account*/) public view returns (uint256) {
        delegateToViewAndReturn();   
    }
    
    function initAirdrop( address /*_optionColPool*/,
                          address /*_minePool*/,
                          address /*_fnxToken*/,
                          address /*_ftpbToken*/,
                          uint256 /*_claimBeginTime*/,
                          uint256 /*_claimEndTime*/,
                          uint256 /*_fnxPerFreeClaimUser*/,
                          uint256 /*_minBalForFreeClaim*/,
                          uint256 /*_maxFreeFnxAirDrop*/,
                          uint256 /*_maxWhiteListFnxAirDrop*/) public {
        delegateAndReturn();
    }
    
    function initSushiMine( address /*_cfnxToken*/,
                            uint256 /*_sushiMineStartTime*/,
                            uint256 /*_sushimineInterval*/) public  {
       delegateAndReturn();
    }
    
    function getbackLeftFnx(address /*_reciever*/)  public {
        delegateAndReturn();
     }
     

    function addWhiteList(address[] memory /*_accounts*/,uint256[] memory /*_fnxnumbers*/) public {
        delegateAndReturn();
    }
    
    
    function whitelistClaim() public {
        delegateAndReturn();
    }
    
    function freeClaim(address /*_targetToken*/) public {
         delegateAndReturn();
    }
    
    function addSushiMineList(address[] memory /*_accounts*/,uint256[] memory /*_fnxnumbers*/) public {
         delegateAndReturn();
    }
    
     function sushiMineClaim() external {
          delegateAndReturn();
     }
    
}
