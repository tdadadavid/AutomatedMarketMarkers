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


    // Swap is used to performa a swap transaction
    // @Parameters
    // _tokenIn(address): is the token the user wants to sell
    // _amountIn (uint): is the amount of tokens the user wants to sell
    // @Returns
    // amountOut(uint): The amount of tokens the user will get in this swap
    function swap(address _tokenIn, uint _amountIn) external returns (uint amountOut) {
      // validation  
      require(_tokenIn == address(token0) || _tokenIn == address(token1), "Invalid token");

      require(_amountIn > 0, "amount must be greater than zero 0");

      
      // determine which token is coming in or out
      // then transfer `_amountIn` of that token to this contract address
      uint amountIn;
      IERC20 tokenOut;
      if (_tokenIn == address(token0)) {
        token0.transferFrom(msg.sender, address(this), _amountIn);

        // get the amount coming in this swap transactions
        amountIn = token0.balanceOf(address(this)) - reserve0;

        // determine the token going in/out
        tokenOut = token1;
      }else {
        token1.transferFrom(msg.sender, address(this), _amountIn);

        // get the amount coming in this swap transactions
        amountIn = token0.balanceOf(address(this)) - reserve1;

        // determine the token going in/out
        tokenOut = token0;
      }

      // calculate the amount going out (include the fees)
      // according to CSAMM dy = dx (amount going out = amount going in, it is a 1:1)
      // but we also have to calculate the fees which is 0.3% of everything sent, so what is
      // recieved is 99.7% of the actual amount
      amountOut = (amountIn * 997) / 1000;


      // update reserves
      if (_tokenIn == address(token0)) {
        _updateReserves(
          reserve0 + amountIn, 
          reserve1 - amountOut
        );
      }else {
        _updateReserves(
          reserve0 - amountOut,
          reserve1 + amountIn
        );
      }


      
      // transfer tokenOut
      tokenOut.transfer(msg.sender, amountOut); 
    }

    function addLiquidity() external {}

    function removeLiquidity() external {}

}
