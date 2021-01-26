# Google-Compromised
Create a Google Sheet and email with details about accounts Google has flagged compromised. Please feel free to help me make this more for any platform. My goal would be for anyone to use this from any type of device. Possibly even combining all of the scripts into one for each platform. Since this is such an important thing to utilize, it should be free for all to use and credit should always be given where credit is due. Google Admin Console can give you some of these reports, but this will allow you to create shared sheets with this information and even email so that your higher ups do not need access to Admin Console or even require you to pull the reports to send to them. I have these reports running with a scheduled task on one of my servers so I can get a daily report as to what is happening with our Gmail accounts. With this report, I was able to easily see different details about the account and went to haveibeenpwnd.com with these accounts and found that most of the accounts were from an "educational" site that got compromised. Wish I had a haveibeenpwnd.com API key so I could integrate that as well, giving the site that was breached in the report.

Thank you so much Ross for dealing with my questions to help me get GAMADV to create these great reports.

I started with compromised.bat. This script will use GAM, I used GAMADV and not sure if you need ADV or not for this to run properly. I would use GAMADV anyway.
Email-compromised.bat will email you a report for the accounts
suspicious.bat will create a sheet which Google reported suspicious.
And various helper scripts.

For all of my reports, I use the same Google sheet utilizing different tabs. I further went into making the information that was uploaded into a "Working" tab and had "Main" sheets that pulled the data from the working sheets and formated them with conditional formatting for things like logins from countries not in the US and color coded for X days since last login and since you filtered out your external IP, it will be x days since last login not on your network.

I am aware that some things are reduntant between scripts and actually useless in particular scripts. I created these in a hurry using the prior for the basis of current.

I am new to Github so bear with me.
