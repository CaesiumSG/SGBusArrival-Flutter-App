# busarrival_utilities

Computer Science Internal Assessment for IB.

Criterias required for the application to work:
1. Internet connection
  - Internet connection is required for the app to query APIs, without any internet connection the application will not function as expected
2. Correct and Specific Time Zone
  - This application utilises Singapore's Timezone (GMT +8) from 6am-1159pm, if you are testing the application outisde of this time period, please wait till the designated timezone and time period or the application will not display any data (which is also intended since there are no overnight bus services operating in singapore)

Notable Interactions
1. When the application launches, the application might require about 5-20 seconds to load background data, please do not perform any action while this is ongoing
2. If you are unsure of locations to type into the search bar, open the "sample bus stop data".json file which contains over 5500 bus stops in singapore. Pick any data from the JSON object properties, including stopDesc ("Hotel Grand Pacific") and stopCode ("01012"). This file is not used by the application as it has its own copy internally within the android filesystem
