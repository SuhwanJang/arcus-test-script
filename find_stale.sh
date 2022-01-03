echo "scrub stale" | nc localhost 11440

if grep -q "Exist" run_11440.log
then
    echo "find stale at 11440"
else
    echo "fsa"
fi

echo "scrub stale" | nc localhost 11441

if grep -q "Exist" run_11441.log
then
    echo "find stale at 11441"
else
    echo "fsa"
fi

echo "scrub stale" | nc localhost 11500

if grep -q "Exist" run_11500.log
then
    echo "find stale at 11500"
else
    echo "fsa"
fi

echo "scrub stale" | nc localhost 11501

if grep -q "Exist" run_11501.log
then
    echo "find stale at 11501"
else
    echo "fsa"
fi
