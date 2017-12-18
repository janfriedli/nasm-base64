#!/bin/bash

## Compile sources
echo 'COMPILING\n'

make
## Decode tests from here on
echo 'RUNNING ENCODE TESTS NOW\n'

# test empty
if [ "$(echo '' | ./encode)" == "" ]; then
  echo -e "\e[92m empty passed"
else
  echo -e "\033[31m empty FAILED"
fi

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

#test lorem ipsum in file
if [ "$(./encode < test/lorem)" == "$(base64 < test/lorem)" ]; then
  echo -e "\e[92m file"
else
  echo -e "\033[31m file FAILED:\n$(./encode < test/lorem) \nexpected \n$(base64 < test/lorem)"
fi


## Decode tests from here on
echo 'RUNNING DECODE TESTS NOW\n'


# test empty
if [ "$(echo '' | ./decode)" == "" ]; then
  echo -e "\e[92m empty passed"
else
  echo -e "\033[31m empty FAILED"
fi

# test single loop no =
if [ "$(echo 'c3Nz' | ./encode)" == "sss" ]; then
  echo -e "\e[92m single loop passed"
else
  echo -e "\033[31m single loop FAILED: (echo 'c3Nz' | ./encode) expected sss"
fi

# test single loop with =
if [ "$(echo 'c2E=' | ./decode)" == "sa" ]; then
  echo -e "\e[92m single loop with = passed"
else
  echo -e "\033[31m single loop with = FAILED: $(echo 'c2E=' | ./decode) expected sa"
fi

# test single loop with ==
if [ "$(echo 'MA==' | ./decode)" == "0" ]; then
  echo -e "\e[92m single loop with == passed"
else
  echo -e "\033[31m single loop with == FAILED: $(echo 'MA==' | ./decode) expected 0"
fi

#----------------------------------------------------------------

# test double loop no =
if [ "$(echo 'c2FzYWFz' | ./decode)" == "sasaas" ]; then
  echo -e "\e[92m double loop passed"
else
  echo -e "\033[31m double loop FAILED: $(echo 'c2FzYWFz' | ./decode) expected sasaas "
fi

# test double loop with =
if [ "$(echo 'c2FzYWE=' | ./decode)" == "sasaa" ]; then
  echo -e "\e[92m double loop with = passed"
else
  echo -e "\033[31m double loop with = FAILED: $(echo 'c2FzYWE=' | ./decode) expected sasaa"
fi

# test double loop with ==
if [ "$(echo 'c2FzYWFzcw==' | ./decode)" == "sasaass" ]; then
  echo -e "\e[92m double loop with == passed"
else
  echo -e "\033[31m double loop with == FAILED: $(echo 'c2FzYWFzcw==' | ./decode) expected sasaass"
fi

# test long
if [ "$(echo 'aXVhc2Rmb2FzZGZrYmFzZGZqYXM=' | ./decode)" == "iuasdfoasdfkbasdfjas" ]; then
  echo -e "\e[92m long with = passed"
else
  echo -e "\033[31m long with = FAILED: $(echo 'aXVhc2Rmb2FzZGZrYmFzZGZqYXM=' | ./decode) expected iuasdfoasdfkbasdfjas"
fi


# test long with space
if [ "$(echo 'aXVhc2Rmb2Egc2Rma2Jhc2RmamFz' | ./decode)" == "iuasdfoa sdfkbasdfjas" ]; then
  echo -e "\e[92m long with space passed"
else
  echo -e "\033[31m long with space FAILED: $(echo 'aXVhc2Rmb2Egc2Rma2Jhc2RmamFz' | ./decode) expected iuasdfoa sdfkbasdfjas"
fi

#test lorem ipsum in file
if [ "$(base64 --decode < test/lorem-base64)" == "$(./decode < test/lorem-base64)" ]; then
  echo -e "\e[92m file"
else
  echo -e "\033[31m file FAILED:\n$(./decode < test/lorem-base64) \nexpected \n$(base64 --decode < test/lorem-base64)"
fi


exit 0
