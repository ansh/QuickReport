# QuickReport

This project won 2nd place at HoyaHacks 2020. It was made by Rami Sbahi, Vishal Dubey, Nigel Veach, and Ansh Nanda.

https://devpost.com/software/quickreport-kd2z7i



## Purpose
Some of the greatest growing concerns that our environment faces today are the degrading quality of our nation’s roads and sidewalks. From giant potholes to cracked sidewalks, from litter on the street to graffiti, communities are struggling from a lack of maintenance. While governments do make it possible to report these issues to them online, the process is not easy. Filling out their convoluted and awkward forms is an incredibly time-intensive and inefficient process. Additionally, few people are even aware that these forms even exist in the first place.

To address these issues in the local city of Arlington, we have created a full-stack mobile/web application called QuickReport. To submit a maintenance request, a user must take a photo of a city maintenance problem. Our app automatically categorizes the type of issue from the photo. It also automatically generates information regarding the location and address of the maintenance issue.

Afterwards, the app directs the user to confirm the submission. Then, all of the information is automatically entered and submitted through a form on Arlington’s website.

## How we built it
We first created our own image based dataset, consisting of nearly 2000 photos through online resources and our own data collection. Our image data was sorted into 5 categories — potholes, graffiti, broken sidewalks, fallen trees, or littering — after we uploaded our dataset to the Google Cloud Console. Through the use of Google’s Cloud AutoML Machine Learning system, we developed a Deep-learning Neural Network Image Classifier that identified images and placed them into one of our five categories with an average precision of 0.988 and a recall of 93%..

Prior to using Google’s Cloud AutoML, we experimented with Apple’s CreateML to develop models for our image classification system. While CreateML served as a useful placeholder, we experienced difficulties in achieving a high enough level of image identification precision with this software. After we managed to get AutoML working, we replaced CreateML with AutoML and our app’s functionality increased significantly.

After creating a working machine learning model, we focused on the app development aspect of our project. We developed both React Native and iOS versions of our app, although only the iOS version is currently fully-featured. We developed a UI to allow the user to change the category of the maintenance request, for the rare cases when AutoML fails to classify the incident correctly. After clicking submit, the information is automatically submitted through Arlington’s service request system. We achieved this through a RESTful API created using the Flask framework, written in Python and hosted on Google Cloud services. Not only did this help us auto-complete the Arlington service request form, but it also allowed us to successfully connect the front-end (the iOS/Android application) and back-end (the client database) of the application.

We developed a GIS-based database using Google’s Maps JavaScript API. Whenever a user submits a maintenance request through the QuickReport app, a GPS marker is added to the database at the location where the user reported the problem. When the marker in the database is selected, the issue’s details, address, attached photo, and other information are easily accessible. Additionally, all of the markers are color-coded according to the type of maintenance issue which they represent (Graffiti = Blue, Sidewalk Repair = Green, Fallen Tree = Red, Litter = Pink, Pothole = Yellow). This allows maintenance workers to quickly identify where the greatest concentration of each type of problems are.

## Challenges
Building the API to automatically fill out the form proved to be one of the most difficult aspects of the development process. While the API was not easy for us to build, the far more difficult part was the hosting process. We experienced many issues with that process, and eventually ended up using a Docker Container to help us finally implement it. The API is hosted on Google Cloud.

Another challenge we faced was exporting photos from the iOS app into the JSON file format which we used for the automation API. We experienced many issues with the imgur API, and it took many hours of trial and error before we eventually succeeded.

A third challenge was building the React Native version of our app. None of us had had much prior React Native experience, causing the development of the React Native version of the app to lag significantly behind the iOS version.

What's next
Moving forward, we aim to release Quick Report as a product. We intend to reach out to cities, like Arlington and Durham (our hometown), in the region. We truly believe that our application would benefit both residents and the government.

From a development standpoint, we will first work to finish the React Native version of our app. This will allow us to have Android functionality, which will be essential as we aim to make our app available to a wider audience. We will also continue to develop the features of our database. While we do have a GIS - oriented database already functional, we believe that other forms of data storage will also prove useful. Exporting our data to Excel, for example, could allow cities to conduct advanced data analysis on their maintenance issues.
