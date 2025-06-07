#!/usr/bin/env bats

@test "check-sys-load prints load averages" {
  run "$BATS_TEST_DIRNAME/../bin/check-sys-load"
  [ "$status" -eq 0 ]
  echo "$output" | grep -q "1-minute"
  echo "$output" | grep -q "2-minute"
  echo "$output" | grep -q "3-minute"
}

