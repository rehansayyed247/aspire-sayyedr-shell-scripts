#!/bin/bash

<< comment
This is just for infotainment purpose
comment

# This is function definition

function is_loyal() {
read -p "$1 ne mud ke kise dekha: " bandi
read -p "$1 ka pyaar %" pyaar

if [[ $bandi == "daya bhabhi"  ]];
then
	echo "$1 is loyal"
elif [[ $pyaar -ge 100 ]];
then
	echo "$1 is loyal"
else
	echo "$1 is not loyal"
fi
}

# This is function call
is_loyal "tom"
