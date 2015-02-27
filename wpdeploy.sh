#!/bin/bash

## Set project specific configurations in a separate config file
CONFIG_FILE=config.cfg

if [[ -f $CONFIG_FILE ]]; then
    . $CONFIG_FILE
  else
		echo "I couldn't find the configuration file with necessary settings."
		echo
		exit 0
fi

## Usage Info
usage(){
	cat << EOF

	OVERVIEW
	tbd

	USAGE
	This should perform a full deploy:
	wpdeploy

	POTENTIAL USAGE EXAMPLES
 	wpdeploy pushto production
	wpdeploy pullfrom production
	wpdeploy pushto staging
	wpdeploy pullfrom staging

	ACCEPTABLE PARAMETERS
	tbd

	EXAMPLES
	tbd

	OPTIONS
	# -db-only
	# -files-only
	-h help
	? help

EOF
}


## Reading the arguments passed to deploy script, e.g., wpdeploy push production local $1 $2
# This is just boilerplate for now. Need to decide options we want. 
case $1 in
	pushto | push )
								;;

	pullfrom | pull )
								;;

	*)
								usage
								exit 1
								;;
esac

case $2 in
	production | prod )
								;;

	staging | stag )
								;;

	development | local )
								;;

	*)
								usage
								exit 1
								;;
esac


function wpdeploy push production local() {

	# check if we are in a git repository
	if git rev-parse --git-dir > /dev/null 2>&1; then

		# check if there any untracked files that need to be commited.
		git ls-files --exclude-standard --others --error-unmatch . >/dev/null 2>&1; ec=$?
		if test "$ec" = 0; then
			echo
			echo "WARNING: There are untracked files in the repo. Exiting the production deployment process now."
			echo
			git status
			echo
			return
		fi
	else
	  echo "This is not a git repository. Ending the deploy process."
	  echo
	  return
	fi

  echo
  # Push to WP Engine's git repo to deploy code changes
  echo "Pushing Code Changes to WP Engine now."
  git push production master
  echo
  # Also push to a standalone repo, e.g., GitHub
  # To Do: provide .gitconfig example that allows / corresponds to these 2 git pushes
  echo "Pushing Code Changes to GitHub repo now."
  git push
  echo
  echo
  echo "Pushing full database to WP Engine now."
  wp migratedb profile 1
  # More info here: https://deliciousbrains.com/wp-migrate-db-pro/doc/cli-profile-subcommand/
  # To do: implement new CLI options: https://deliciousbrains.com/wp-migrate-db-pro/doc/cli-push-pull-subcommand/
  echo
  echo
}


# Here are the actual deployment tasks / functions
echo '\n... begin ...'
wpdeploy pushto production
echo '... done...\n\n'
