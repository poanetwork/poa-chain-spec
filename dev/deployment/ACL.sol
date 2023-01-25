pragma solidity ^0.4.24;

contract ACL {
    /// Allowed transaction types mask
    uint32 constant NONE_MASK = 0;
    uint32 constant ALL_MASK = 0xffffffff;
    uint32 constant BASIC_MASK = 0x01;
    uint32 constant CALL_MASK = 0x02;
    uint32 constant CREATE_MASK = 0x04;
    uint32 constant PRIVATE_MASK = 0x08;

    uint32 private _defaultPermission;

    mapping (address => bool) private _permissionned;

    mapping (address => uint32) private _permissions;

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    event PermissionChanged(address indexed account, uint32 oldPermission, uint32 newPermission);

    event DefaultPermissionChanged(uint32 oldDefaultPermission, uint32 newDefaultPermission);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner and defaultPermission to:  BASIC_MASK | CALL_MASK
     */
    constructor () public {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), msg.sender);
        _defaultPermission = BASIC_MASK | CALL_MASK;
    }


    modifier onlyOwner() {
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev ownership change functions
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    /**
     * @dev permissions change functions
     */
    function setDefaultPermission(uint32 newDefaultPermission) public onlyOwner {
        emit DefaultPermissionChanged(_defaultPermission,newDefaultPermission);
        _defaultPermission = newDefaultPermission;
    }

    function setPermission(address account,uint32 permission) public onlyOwner {
        _setPermission(account,permission);
    }

    function setPermissionNone(address account) public onlyOwner {
        _setPermission(account,NONE_MASK);
    }

    function setPermissionAll(address account) public onlyOwner {
        _setPermission(account,ALL_MASK);
    }

    function setPermissionBasic(address account) public onlyOwner {
        _setPermission(account,BASIC_MASK);
    }

    function setPermissionCall(address account) public onlyOwner {
        _setPermission(account,CALL_MASK);
    }

    function setPermissionPrivate(address account) public onlyOwner {
        _setPermission(account,PRIVATE_MASK);
    }

    function setPermissionBasicCall(address account) public onlyOwner {
        _setPermission(account,BASIC_MASK | CALL_MASK);
    }

    function _setPermission(address account,uint32 permission) internal {
        require(account != address(0));
        emit PermissionChanged(account,_permissions[account],permission);
        _permissionned[account] = true;
        _permissions[account] = permission;
    }

     /**
     * @dev Views
     */
    function owner() public view returns (address) {
        return _owner;
    }

    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    function permission(address account) public view returns (uint32) {
        return _permissions[account];
    }

    function permissionned(address account) public view returns (bool) {
        return _permissionned[account];
    }

    function defaultPermission() public view returns (uint32) {
        return _defaultPermission;
    }

    function allowedTxTypes(address sender) public view returns (uint32)
    {
        if(_permissionned[sender]){
            return _permissions[sender];
        }
        else{
            return _defaultPermission;
        }
    }




}