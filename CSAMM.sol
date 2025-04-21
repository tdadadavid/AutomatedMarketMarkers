// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

import "./IERC20.sol";

contract CSAMM {
    IERC20 public immutable token0;
    IERC20 public immutable token1;

    // keeps track of the amount of tokens available in this contract (liquidity pool)
    uint public reserve0;
    uint public reserve1;

    // total shares
    uint public totalSupply;
    // shares for each user
    mapping(address => uint) public balanceOf;

    constructor(address _token0, address _token1) {
        token0 = IERC20(_token0);
        token1 = IERC20(_token1);
    }

    function _mint(address _to, uint _amount) private {
      balanceOf[_to] += _amount;
      totalSupply += _amount;
    }

    function _burn(address _from, uint _amount) private {
      balanceOf[_from] -= _amount;
      totalSupply -= _amount;
    }

    function _updateReserves(uint _reserve0, uint _reserve1) private {
      reserve0 = _reserve0;
      reserve1 = _reserve1;
    }

    function swap(address _tokenIn, uint _amountIn) external returns (uint amountOut) {
    
    }

    function addLiquidity() external {}

    function removeLiquidity() external {}

}
