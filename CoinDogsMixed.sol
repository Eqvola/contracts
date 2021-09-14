// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./CoinDogs.sol";
import "./CoinDogsAccessories.sol";
import "./CoinDogsTestERC20.sol";
import "./utils/Strings.sol";
import "./utils/math/SafeMath.sol";
import "./Delegable.sol";

contract CoinDogsMixed is Delegable{
    using Strings for string;
    using SafeMath for uint256;
    
    mapping (address => mapping(uint256 => uint256)) private used_accessories;
    mapping(uint256 => mapping(uint256 => uint256) ) private weared_accessories;
    string public name;
    string public symbol;
    CoinDogsTestERC20 private erc20;
    CoinDogs private dogs;
    CoinDogsAccessories private accessories;
    uint256 private dogCoinsRate;
    
    //uint256 constant TYPE_MASK = 0xffffffffffffffff << 128;
    //uint256 constant NF_INDEX_MASK = uint256(uint128(~0));
    uint256 constant TYPE_NF_BIT = 1 << 255;
    
    constructor(address erc20_, address dogs_, address accessories_){
        erc20 = CoinDogsTestERC20(erc20_);
        dogs = CoinDogs(dogs_);
        accessories = CoinDogsAccessories(accessories_);
        name = "CryptoDogs Factory";
        symbol = "CDOGF";
    }
    
    
    function buyDogCoins() external payable {
        uint256 dogCoinsAmount = dogCoinsRate * msg.value;
        require(dogCoinsAmount > 0, "Must send ETH to purchase dog coins.");
        
        erc20.mint(_msgSender(), dogCoinsAmount);
    }

    function setCoinDogsRate(uint256 rate) onlyOwner external{
        require(rate > 0, "Illegal rate");
        dogCoinsRate = rate;
    }
    
    function getCoinDogsRate() external view returns (uint256){
        
        return dogCoinsRate;
    }

    function transferContractsOwnership(address newowner) onlyOwner external{
        erc20.transferOwnership(newowner);
        dogs.transferOwnership(newowner);
        accessories.transferOwnership(newowner);
    }
    
    function createDog(address _to,
        uint256 _id,
        string memory _uri
        )onlyOwner external {
        dogs.mint(_to, _id, _uri);
    }
    
    function createAccessory(address _to,
        uint256 _id,
        uint256 cnt,
        string memory _uri
        )onlyOwner external {
        accessories.mint(_to, _id, cnt, _uri);
    }

    function safeTransferFrom(address _from, address _to, uint256 _id, uint256 _value, bytes calldata _data) external {
        if (_id & TYPE_NF_BIT == TYPE_NF_BIT) { // is NFT
            dogs.transferFrom(_from,_to,_id);
        } else {
            accessories.safeTransferFrom(_from,_to,_id,_value,_data);
        }


    }
    
    function safeBatchTransferFrom(address _from, address _to, uint256[] calldata _ids, uint256[] calldata _values, bytes calldata _data) external {

        require(_to != address(0x0), "cannot send to zero address");
        require(_ids.length == _values.length, "Array length must match");

        for (uint256 i = 0; i < _ids.length; ++i) {
            // Cache value to local variable to reduce read costs.
            uint256 id = _ids[i];
            uint256 value = _values[i];

            if (id & TYPE_NF_BIT == TYPE_NF_BIT) {
                dogs.transferFrom(_from,_to,id);
            } else {
                accessories.safeTransferFrom(_from,_to,id,value,_data);
            }
        }
    }
    function balanceOf(address _owner, uint256 _id) external view returns (uint256) {
        if (_id & TYPE_NF_BIT == TYPE_NF_BIT)
            return dogs.ownerOf(_id)==_owner ? 1 : 0;
        return accessories.balanceOf(_owner,_id);
    }

    function balanceOfBatch(address[] calldata _owners, uint256[] calldata _ids) external view returns (uint256[] memory) {

        require(_owners.length == _ids.length);

        uint256[] memory balances_ = new uint256[](_owners.length);

        for (uint256 i = 0; i < _owners.length; ++i) {
            uint256 id = _ids[i];
            if (id & TYPE_NF_BIT == TYPE_NF_BIT) {
                balances_[i] = dogs.ownerOf(id) == _owners[i] ? 1 : 0;
            } else {
            	balances_[i] = accessories.balanceOf(_owners[i],id);
            }
        }

        return balances_;
    }
    
    function withdraw(address payable to, uint256 amount) external onlyOwner {
        require(to != address(0), "Zero address prohibited");
        uint256 contractBalance = address(this).balance;
        require(amount <= contractBalance, "Insufficient contract BNB balance");
        to.transfer(amount);
    }

}
