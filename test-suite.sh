#!/bin/bash
make

# test single loop no =
if [ "$(echo 'sss' | ./encode)" == "c3Nz" ]; then
  echo -e "\e[92m single loop passed"
else
  echo -e "\033[31m single loop FAILED: $(echo 'sss' | ./encode) expected c3Nz"
fi

# test single loop with =
if [ "$(echo 'sa' | ./encode)" == "c2E=" ]; then
  echo -e "\e[92m single loop with = passed"
else
  echo -e "\033[31m single loop with = FAILED: $(echo 'sa' | ./encode) expected c2E="
fi

# test single loop with ==
if [ "$(echo '0' | ./encode)" == "MA==" ]; then
  echo -e "\e[92m single loop with == passed"
else
  echo -e "\033[31m single loop with == FAILED: $(echo '0' | ./encode) expected MA=="
fi

#----------------------------------------------------------------

# test double loop no =
if [ "$(echo 'sasaas' | ./encode)" == "c2FzYWFz" ]; then
  echo -e "\e[92m double loop passed"
else
  echo -e "\033[31m double loop FAILED: $(echo 'sasaas' | ./encode) expected c2FzYWFz"
fi

# test double loop with =
if [ "$(echo 'sasaa' | ./encode)" == "c2FzYWE=" ]; then
  echo -e "\e[92m double loop with = passed"
else
  echo -e "\033[31m double loop with = FAILED: $(echo 'sasaa' | ./encode) expected c2FzYWE="
fi

# test double loop with ==
if [ "$(echo 'sasaass' | ./encode)" == "c2FzYWFzcw==" ]; then
  echo -e "\e[92m double loop with == passed"
else
  echo -e "\033[31m double loop with == FAILED: $(echo 'sasaass' | ./encode) expected c2FzYWFzcw=="
fi

# test long
if [ "$(echo 'iuasdfoasdfkbasdfjas' | ./encode)" == "aXVhc2Rmb2FzZGZrYmFzZGZqYXM=" ]; then
  echo -e "\e[92m long with = passed"
else
  echo -e "\033[31m long with = FAILED: $(echo 'iuasdfoasdfkbasdfjas' | ./encode) expected aXVhc2Rmb2FzZGZrYmFzZGZqYXM="
fi


# test long with space
if [ "$(echo 'iuasdfoa sdfkbasdfjas' | ./encode)" == "aXVhc2Rmb2Egc2Rma2Jhc2RmamFz" ]; then
  echo -e "\e[92m long with space passed"
else
  echo -e "\033[31m long with space FAILED: $(echo 'iuasdfoa sdfkbasdfjas' | ./encode) expected aXVhc2Rmb2Egc2Rma2Jhc2RmamFz"
fi

exit 0
