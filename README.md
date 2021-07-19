# DialogueSystem-CC-Tweaked
A system for adding dialogue to and talking with the computers in Computer Craft - Tweaked.

REQUIRES: Computercraft Tweaked 1.16.5, Advanced Peripherals 1.16.5

  Firstly the turtles need monitors in their first slot and to be manually fueled. They won't use up fuel fast at all though (they only move like 4 blocks), so it should 
be an extremely rare occurance for you to have to fuel them. The turtles also require a modem on the left side to work.

  This system uses two turtles with modems to talk to eachother and to the player. One turtle runs the Hivemind code, the other the Terminal code. The hivemind stores all
dialogue and data for the turtles the player will interact with. The terminal code reads its label and requests dialogue options / responses to the player based on its
label. This information (fill = {{color code, response to player choice} {button index IDs in dialogue tree} and {the labels for the buttons to choose dialogue from}}) is 
sent to the terminal in a single table called 'fill'.

  The dialogue system uses indexes, and current and target IDs set in the dialogue tree for each branch of dialogue. A branch with {"something","something",1,2} has a current 
ID of 1, and a target ID of 2. The system gets the target ID of whatever index corresponds to the players button choice, and fills a list with every branch with a matching 
current ID. So in a tree like this:

local tree = { 
    simon = {
        fill = {{32,""},{},{"Error: Missing button label"}},--{Text color, response string}{target IDs}{button labels}
        {"Goodbye","Bye!",0,0}, --ID pairs like this are used to end the conversation. Will generate only a goodbye button.
        {"","Hello, I'm Simon.",1,2},
        {"Nice weather today!","My data indicates the weather is within acceptable parameters.",2,3},
        {"Your floppy disk is out!","I am not capable of hate. But if I was, I'd hate you.",3,1},
        {"Did you polish your monitor?","Thanks for noticing.",3,0}
        }
}

  If the player chose the button corresponding to index 3 ("Nice weather today"), it would look for whatever the target ID of index 3 is (3) and fill the list with those pairs 
with the current ID as the target ID. The new index list would now be {4,5} because indexs 4 and 5 have current IDs matching that of our target (3). Our terminal code would
then display the following buttons as options for the player:

[1] Your floppy disk is out!       --This has a stored index value of 4
[2] Did you polish your monitor?   --This has a stored index value of 5
[3] Goodbye

  Choosing 1 or 2 would then return whatever index value corresponds to that choice, and the cycle repeats until its brought to a 0,0 branch (index 1 in our example table)
(in which case the only option the player will have is whatever the goodbye button label is set to) or until our player chooses the goodbye option.

  The first index in the first table in fill is used to assign color codes to the responses for that turtle. Simon has a color decimal code of 32 which is green. You can use
anything that will work for the term.setTextColor() command, as it just jams whatever is in tree[name].fill[1][1] into that and sets it back to default when its done.

  Note that currently non-alphabetical (not including spaces) characters are not accepted as names. A name of 'Space Cowboy' will work fine but for the purposes of getting a fill
table, will be reformatted to 'spacecowboy' (removed capitalization and spaces) and should be programmed into the list accordingly.

  The hivemind also outputs whatever its doing to a monitor above it. This can be removed by simply removing every mention of the bug() function and anything requiring a monitor to
run, as the hivemind itself has no use for a monitor. Though, I wouldn't reccomend doing so (for the purposes of debugging).
