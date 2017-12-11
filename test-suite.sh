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
  exit 1
fi

# test single loop with ==
if [ "$(echo '0' | ./encode)" == "MA==" ]; then
  echo -e "\e[92m single loop with == passed"
else
  echo -e "\033[31m single loop with == FAILED: $(echo '0' | ./encode) expected MA=="
  exit 1
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

exit 1
