# tf330

TF330 source files. 

Published under GPL v2. 

TF330 is distributed with absolutely no warranty. If you make a mistake you could blow up your CD32. I take no responsibility for this. 

The TF330 is an 030 accelerator fixed at 50Mhz with 64Mb of SDRAM (128Mb possible), WIFI support (via ESP8266) and is intended to work with CF cards or IDE2SD card type devices. The IDE interface does not work with long cables. It is intended to be CHEAP Because thats pretty much all Amiga users care about. 

If you have poor soldering skills and feel the need to mock me for not using through hole technology please dont bother. I've heard it all before and I will just laugh at you. Through hole sucks. 

Also do not ask me to reroute the board to a different DRC so you can use your local boardhouse. I dont feel like spending 100 hours of my time to save you $10. The DRC on this board is 7-7-7 and any boardhouse that doesnt totally suck can do this. Also it 4 layer and dont ask if i can be made 2 layer. The answer is no. 

If you need help with this the best place to get it is the exxos forum https://www.exxoshost.co.uk/forum/ 

Please do not message me directly. Start a thread. 

I do my best to help people who ask polite questions in public but if you make your inadequecies my problem then you are on your own. 

![alt text](https://github.com/terriblefire/tf330/raw/master/top.png "Top of board")

![alt text](https://github.com/terriblefire/tf330/raw/master/bottom.png "Bottom of board")

I dont care if you think my HDL is not pristine either. It works perfecly fine for what its intended to be. I lothe the wordy VHDL language.. it breaks the most basic principle of coding .. .DONT REPEAT YOURSELF. 

The SDRAM Controller is derived from my Archie core and the clock controller code is designed to simulate a PLL with adjustable phase. 

This is not an exercise in German over engineering. Its properly engineered to do an exact task and nothing more. Its a simple repeatable board that works and there are about 500 of them built and working reliably.

I dont like forks because i dont like options. Options mean more testing and more testing = time. So if you fork you are on your own but if you fork and dont give credit I will make it my mission in life to punish you. I will summon the ancient spirits of evil like Jack Tramiel and have them haunt you for all time. You have been warned. 

I know this seems a bit hostile but really its just from hard experience of Amiga people. I give this out for free but there are people out there who will take the piss and try to rip off amiga users with clones baring their own name, others will get one of these off ebay for £15 and expect me to invest 100s of hours in helping them get it going. Yet others will try to be smart arses and tell me i've done X, Y or Z wrong and this will never work. If for any reason you decide this board does not measure up to whatever standard YOU think it should be... take a hike. I dont care. 

On the other hand if you have an actual firmware bugfix send me a pull request with testing evidence. It will be appreciated greatly. 

For crashes please check that the crash doesnt happen in WinUAE for a CD32 with A1200 IDE and 64MB ZIII Ram before making a bug report. Most of the crashes we have seen over the years are repeatable in that environment. 

This version of the board is cloned from my private repository and is GPL. The version in my private repo is not GPL and anything derived from it is not subject to the GPL v2.
