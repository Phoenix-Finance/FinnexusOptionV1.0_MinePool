
pragma solidity >=0.5.16;
/**
 * SPDX-License-Identifier: GPL-3.0-or-later
 * FinNexus
 * Copyright (C) 2020 FinNexus Options Protocol
 */
contract once {

  /**
   * @dev We use a single lock for the whole contract.
   */
  mapping (uint256=>bool) private onceMap;
  modifier doOnce(uint256 id) {
    require(!onceMap[id]);
    onceMap[id] = true;
    _;
  }

}