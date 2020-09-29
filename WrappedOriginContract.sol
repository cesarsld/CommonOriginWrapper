pragma solidity ^0.7.0;

interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);
    function balanceOf(address owner) external view returns (uint256 balance);
    function ownerOf(uint256 tokenId) external view returns (address owner);
    function safeTransferFrom(address from, address to, uint256 tokenId) external;
    function transferFrom(address from, address to, uint256 tokenId) external;
    function approve(address to, uint256 tokenId) external;
    function getApproved(uint256 tokenId) external view returns (address operator);
    function setApprovalForAll(address operator, bool _approved) external;
    function isApprovedForAll(address owner, address operator) external view returns (bool);
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;
}

library SafeMath {
	function add(uint256 a, uint256 b) internal pure returns (uint256) {
		uint256 c = a + b;
		require(c >= a, "SafeMath: addition overflow");

		return c;
	}
	function sub(uint256 a, uint256 b) internal pure returns (uint256) {
		return sub(a, b, "SafeMath: subtraction overflow");
	}
	function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
		require(b <= a, errorMessage);
		uint256 c = a - b;

		return c;
	}
	function mul(uint256 a, uint256 b) internal pure returns (uint256) {
		if (a == 0) {
			return 0;
		}

		uint256 c = a * b;
		require(c / a == b, "SafeMath: multiplication overflow");

		return c;
	}
	function div(uint256 a, uint256 b) internal pure returns (uint256) {
		return div(a, b, "SafeMath: division by zero");
	}
	function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
		// Solidity only automatically asserts when dividing by 0
		require(b > 0, errorMessage);
		uint256 c = a / b;

		return c;
	}
	function mod(uint256 a, uint256 b) internal pure returns (uint256) {
		return mod(a, b, "SafeMath: modulo by zero");
	}
	function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
		require(b != 0, errorMessage);
		return a % b;
	}
}

interface IERC20 {
	function totalSupply() external view returns (uint256);
	function balanceOf(address account) external view returns (uint256);
	function transfer(address recipient, uint256 amount) external returns (bool);
	function allowance(address owner, address spender) external view returns (uint256);
	function approve(address spender, uint256 amount) external returns (bool);
	function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
	event Transfer(address indexed from, address indexed to, uint256 value);
	event Approval(address indexed owner, address indexed spender, uint256 value);
}

abstract contract ERC20 is IERC20 {
	using SafeMath for uint256;

	string public name;
	string public symbol;
	uint8 public decimals;

	uint256 public _totalSupply;
	mapping (address => uint256) public _balanceOf;
	mapping (address => mapping (address => uint256)) public _allowance;

	constructor (string memory _name, string memory _symbol, uint8 _decimals) 
	{
		name = _name;
		symbol = _symbol;
		decimals = _decimals;
	}

	function totalSupply() public view override returns (uint256) {
		return _totalSupply;
	}

	function balanceOf(address account) public view override returns (uint256) {
		return _balanceOf[account];
	}
	function allowance(address owner, address spender) public view override returns (uint256) {
		return _allowance[owner][spender];
	}

	function approve(address _spender, uint256 _value) public override returns (bool _success) {
		_allowance[msg.sender][_spender] = _value;
		emit Approval(msg.sender, _spender, _value);
		return true;
	}

	function transfer(address _to, uint256 _value) public override returns (bool _success) {
		require(_to != address(0), "Recipient address is null.");
		_balanceOf[msg.sender] = _balanceOf[msg.sender].sub(_value);
		_balanceOf[_to] = _balanceOf[_to].add(_value);
		emit Transfer(msg.sender, _to, _value);
		return true;
	}

	function transferFrom(address _from, address _to, uint256 _value) public override returns (bool _success) {
		require(_to != address(0), "Recipient address is null");
		_balanceOf[_from] = _balanceOf[_from].sub(_value);
		_balanceOf[_to] = _balanceOf[_to].add(_value);
		_allowance[_from][msg.sender] = _allowance[_from][msg.sender].sub(_value);
		emit Transfer(_from, _to, _value);
		return true;
	}

	function _mint(address _to, uint256 _amount) internal
	{
		_totalSupply = _totalSupply.add(_amount);
		_balanceOf[_to] = _balanceOf[_to].add(_amount);
		emit Transfer(address(0), _to, _amount);
	}

	function _burn (address _account, uint _amount) internal {
		require(_account != address(0), "Burning from address 0");

		_balanceOf[_account] = _balanceOf[_account].sub(_amount, "ERC20: burn amount exceeds balance");
		_totalSupply = _totalSupply.sub(_amount);
		emit Transfer (_account, address(0), _amount);
	}
}

interface AxieCore{
	function getAxie(uint256 _axieId) external view returns (uint256 /* _genes */, uint256 /* _bornAt */);
}

contract WrappedOrigin is ERC20 {
	using SafeMath for uint256;

	address public constant AXIE_NFT_ADDRESS = address(0xF5b0A3eFB8e8E4c201e2A935F110eAaF3FFEcb8d);

	uint[] private axieList;

	mapping (uint256 => bool) private unwrappableAxie;

	constructor (string memory _name, string memory _symbol, uint8 _decimals) ERC20(_name, _symbol, _decimals) {}

	function inPool() public view returns(uint) {
		return axieList.length;
	}

	function isValidOrigin(uint tokenId) internal view returns(bool) {
		uint genes;
		(genes,) = AxieCore(AXIE_NFT_ADDRESS).getAxie(tokenId);
		genes = (genes >> 238) & 1;
		if (genes == 1)
			return true;
		return false;
	}

	function wrap(uint[] calldata tokenIds) external {
		require (tokenIds.length > 0, "array is empty");
		for (uint i = 0; i < tokenIds.length; i++) {
			require (isValidOrigin(tokenIds[i]), "Not origin axie");
			axieList.push(tokenIds[i]);
			unwrappableAxie[tokenIds[i]] = true;
			IERC721(AXIE_NFT_ADDRESS).safeTransferFrom(msg.sender, address(this), tokenIds[i]);
		}
		_mint(msg.sender, tokenIds.length * 10**decimals);
	}

	function unwrap() external {
		_burn(msg.sender, 10**decimals);
		uint index = getRandomValue() % axieList.length;
		uint tokenId = axieList[index];
		axieList[index] = axieList[axieList.length - 1];
		delete axieList[axieList.length - 1];
		IERC721(AXIE_NFT_ADDRESS).safeTransferFrom(address(this), msg.sender, tokenId);
	}

	function unwrap(uint[] calldata tokenIds, address recipient) external {
		if (recipient == address(0))
			recipient = msg.sender;
		uint toBurn = tokenIds.length;
		for (uint i = 0; i < tokenIds.length; i++) {
			require (unwrappableAxie[tokenIds[i]], "Axie not in wrap contract");
			unwrappableAxie[tokenIds[i]] = false;
			_swapAndDeleteAxie(_getIndex(tokenIds[i]));
			IERC721(AXIE_NFT_ADDRESS).safeTransferFrom(address(this), recipient, tokenIds[i]);
		}
		_burn(msg.sender, toBurn * 10**decimals);
	}

	function getRandomValue() internal returns(uint){
		return 0;
	}

	function _getIndex(uint tokenId) internal view returns(uint) {
		for (uint i = 0; i < axieList.length; i++) {
			if (axieList[i] == tokenId)
				return i;
		}
	}

	function _swapAndDeleteAxie(uint index) internal {
		axieList[index] = axieList[axieList.length - 1];
		axieList.pop();
	}

	function onERC721Received(address _operator, address _from, uint256 _tokenId, bytes calldata _data) external view returns (bytes4) {
		require (msg.sender == AXIE_NFT_ADDRESS, "Not Axie NFT");
		return WrappedOrigin.onERC721Received.selector;
	}
}