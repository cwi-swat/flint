

if [ "a$1" == "a" ]; then
    echo "Usage: flint2json.sh <absolutepathtoflintfile>"
    exit 1
fi
   

(
    cd src
    java -cp ../lib/rascal-shell-unstable.jar org.rascalmpl.shell.RascalShell Flint2JSON.rsc $1
)

