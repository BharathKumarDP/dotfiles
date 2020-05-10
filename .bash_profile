# Add `~/bin` to the `$PATH`
export PATH="$HOME/bin:$PATH";

# Load the shell dotfiles, and then some:
# * ~/.path can be used to extend `$PATH`.
# * ~/.extra can be used for other settings you don’t want to commit.
for file in ~/.{path,bash_prompt,exports,aliases,functions,extra}; do
	[ -r "$file" ] && [ -f "$file" ] && source "$file";
done;
unset file;


alias winhome="cd /mnt/c/users/ELCOT";
alias edu="cd /mnt/d";

# My function to compile C and C++ easily
function compile() {

	for file in $@; do
		local extension=${file#*.};
		local executable=${file%.*};
		case $extension in
			c)
				gcc -o $executable $file;
				;;
			cpp)
				g++ -o $executable $file;
				;;
			*)
				echo "INVALID EXTENSION";
				;;
		esac
	done

}

# My function to run C and C++ executable files easily
function run() {
	
    for file in $@; do
		local executable=${file%.*};
		if  [ -e $executable ]; then
			echo -e "\n----- Running : ${file} -----\n";
			./$executable;
		else
			echo -e "\n----- Running : ${file} -----\n";
			compile $file;
			./$executable;
		fi
	done

}


#My function to give outline to C and C++ files

function out() {
    
    if [ $# -eq 0 ]; then
        echo "Too Few Arguments";
        return;
    elif [ $# -gt 2 ]; then
        echo "Too Many Arguments";
        return;
    fi

    for temp in $@; do
        case $temp in
            -*)
                local flag=$temp;
                ;;
            *.c)
                local file=$temp;
                ;;
            *.cpp)
                local file=$temp;
                ;;
            *)
                echo "Invalid Argument";
                return;
                ;;
        esac
    done

    if [ -z ${file+x} ]; then
        echo "File Name Recquired";
        return;
    else
        local extension=${file#*.};
        local source="outline."$extension;
        if [ -e $file ]; then
            echo "File Already exists";
            read -p "Do You Wanna replace its contents?[Y/N] : " permission;

            if [ $permission == n -o $permission == N ]; then
                return;
            fi
        fi
        touch $file;
        cp ~/$source $file;
    fi

    if [ ! -z ${flag+x} ]; then
        if [ $flag == "-v" ]; then
            vim $file;
        elif [ $flag == "-c" ]; then
            code -r $file;
        else
            echo "Invalid Flag";
        fi
    fi


}

# Case-insensitive globbing (used in pathname expansion)
shopt -s nocaseglob;

# Append to the Bash history file, rather than overwriting it
shopt -s histappend;

# Autocorrect typos in path names when using `cd`
shopt -s cdspell;

# Enable some Bash 4 features when possible:
# * `autocd`, e.g. `**/qux` will enter `./foo/bar/baz/qux`
# * Recursive globbing, e.g. `echo **/*.txt`
for option in autocd globstar; do
	shopt -s "$option" 2> /dev/null;
done;

# Add tab completion for many Bash commands
if which brew &> /dev/null && [ -r "$(brew --prefix)/etc/profile.d/bash_completion.sh" ]; then
	# Ensure existing Homebrew v1 completions continue to work
	export BASH_COMPLETION_COMPAT_DIR="$(brew --prefix)/etc/bash_completion.d";
	source "$(brew --prefix)/etc/profile.d/bash_completion.sh";
elif [ -f /etc/bash_completion ]; then
	source /etc/bash_completion;
fi;

# Enable tab completion for `g` by marking it as an alias for `git`
if type _git &> /dev/null; then
	complete -o default -o nospace -F _git g;
fi;

# Add tab completion for SSH hostnames based on ~/.ssh/config, ignoring wildcards
[ -e "$HOME/.ssh/config" ] && complete -o "default" -o "nospace" -W "$(grep "^Host" ~/.ssh/config | grep -v "[?*]" | cut -d " " -f2- | tr ' ' '\n')" scp sftp ssh;

# Add tab completion for `defaults read|write NSGlobalDomain`
# You could just use `-g` instead, but I like being explicit
complete -W "NSGlobalDomain" defaults;

# Add `killall` tab completion for common apps
complete -o "nospace" -W "Contacts Calendar Dock Finder Mail Safari iTunes SystemUIServer Terminal Twitter" killall;