RAND_MAX=32767 
N_USERS=4
N_BRANCHES=5
N_FILES=30
N_COMMITS_PRE=10
N_COMMITS=30
BUG_PROBABILITY=5

# modific
probability_selector() {
    return $((RANDOM < RAND_MAX*$(($1+1))/100))
}

random_user() {
    num=$((RANDOM%N_USERS))
    echo Random Bob$num \<bob_$num@fake.com\>
}

random_message() {
    echo `curl -s whatthecommit.com/index.txt`
}

random_branch() {
    echo branch_$((RANDOM%N_BRANCHES))
}

random_file() {
    echo file_$((RANDOM%N_FILES))
}

init_repository() {
    rm -rf .git test feature
    git init .
    mkdir test feature
    touch test/.gitignore 
    touch feature/.gitignore
    git add test/.gitignore 
    git add feature/.gitignore
    git commit -m 'Initial commit'
    i="0"
    while [ $i -lt $N_BRANCHES ]
    do
	git checkout -b branch_$i
	i=$[$i+1]
    done
}

random_commit() {
    git add feature/* test/*
    git commit --author "$user" -am "`random_message`"
    file=`random_file`
    user=`random_user`
    if $(($1<N_COMMITS_PRE)); then 
	test_msg=$user was ok here
    else
	test_msg=`probability_selector $BUG_PROBABILITY && echo $user was not ok here \
		  || echo $user was ok here`
    fi
    git checkout `random_branch`
    echo $user was ok here >> feature/$file
    echo $test_msg >> test/$file
    git add feature/$file  test/$file
    git commit --author "$user" -m "`random_message`"
}

test_repo() {
    for file in feature/*; do 
      diff $file test/`basename $file` || return 1 
    done
    return 0
}

run_repo() {
    while [ $i -lt $N_COMMITS ]
    do
        random_commit
        i=$[$i+1]
    done    
}


