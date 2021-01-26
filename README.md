# Google-Compromised
Create a Google Sheet and email with details about accounts Google has flagged compromised. Please feel free to help me make this more for any platform. My goal would be for anyone to use this from any type of device. Possibly even combining all of the scripts into one for each platform. Since this is such an important thing to utilize, it should be free for all to use and credit should always be given where credit is due.

I started with compromised.bat. This script will use GAM, I used GAMADV and not sure if you need ADV or not for this to run properly. I would use GAMADV anyway.

Compromised.bat
I have mine set to grab the date of June 01 of current school year. For me this is after the prior school year ended so I am starting fresh for the summer until school ends. Adjust to you needs.
I then remove all prior "working" CSV files an create the headers for the new CSV to be uploaded.

Next, use GAM to grab all accounts Google has reported as compromised since <date>. I then use powershell to remove all duplicate email addresses since I only need to parse them once. I'll read through the CSV and create variables for the next step.
Filter out your internet facing IP address because you really only want to know where students are logging in outside your district.
