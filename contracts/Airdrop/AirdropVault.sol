pragma solidity =0.5.16;
import "./AirDropVaultData.sol";
import "../modules/SafeMath.sol";
import "../ERC20/IERC20.sol";


interface IOptionMgrPoxy {
    function addCollateral(address collateral,uint256 amount) external payable;
}

interface IMinePool {
    function lockAirDrop(address user,uint256 ftp_b_amount) external;
}

contract AirDropVault is AirDropVaultData {
    using SafeMath for uint256;
    

    function initialize() onlyOwner public {
    }
    
    function update() onlyOwner public{
    }
    
    function setOptionColPool(address _optionColPool) public onlyOwner {
        optionColPool = _optionColPool;
    }
    
    function setMinePool( address _minePool) public onlyOwner {
        minePool = _minePool;
    }
    
    function setFnxToken(address _fnxToken) public onlyOwner {
        fnxToken = _fnxToken;
    }
   
    function setFptbToken(address _ftpbToken) public onlyOwner {
        ftpbToken = _ftpbToken;
    }
    
    function setTotalAirdropFnx(uint256 _totalAirdropFnx) public onlyOwner {
        totalAirdropFnx = _totalAirdropFnx;
    }

    function setFnxPerPerson(uint256 _fnxPerPerson)  public onlyOwner {
        fnxPerPerson = _fnxPerPerson;
    }
    
    /**
     * @dev getting back the left mine token
     * @param reciever the reciever for getting back mine token
     */
    function getbackLeftFnx(address reciever)  public onlyOwner {
        uint256 bal =  IERC20(fnxToken).balanceOf(address(this));
        IERC20(fnxToken).transfer(reciever,bal);
    }  

    /**
     * @dev Retrieve user's locked balance. 
     * @param account user's account.
     */ 
    function balanceOfAirdrop(address account) public view returns (uint256) {
        return airDropWhiteList[account];
    }


    function addWhiteList(address account) external {
        airDropWhiteList[account] = fnxPerPerson;
    }
    
    
    function claim() external {
        require(airDropWhiteList[tx.origin]>0);
        uint256 amount = airDropWhiteList[tx.origin];
        airDropWhiteList[tx.origin] = 0;
        uint256 prefptb = IERC20(ftpbToken).balanceOf(address(this));
        IOptionMgrPoxy(optionColPool).addCollateral(fnxToken,amount);
        uint256 afterftpb = IERC20(ftpbToken).balanceOf(address(this));
        uint256 ftpbnum = afterftpb.sub(prefptb);
        IMinePool(minePool).lockAirDrop(tx.origin,ftpbnum);
    }
    
}
