# Predicting resto popularity
Niko Strijbol

**Note**: this a very preliminary draft at the moment, might be complete nonsense.

## _Abstract_

This document details how the popularity prediction for student restaurants (_restos_) is done. We use the available data to predict the number of customers based on the menu and the date

## Introduction

When deciding what to eat, one factor that is considered is how busy the place is. Since the food in all restos is of the same quality, a less crowded resto is always a positive (when the quality of the food is not known, a restaurant with few customers might indicate something is wrong with either the price, the food or both).

On the flip side, overcrowded restos are a deterrent. However, there is currently no good indicator of the business of a resto, except for some general knowledge (e.g. when a popular dish is served, we expect more students). We want to change this: if we can reliably predict business, students would be saved the trip of going to a resto, only to see that there is no more room for them.

## Available data

We have following data, which may be usable as possible indicators:

- Each day has a menu (per resto). This comes from our API.
- Transactions per resto. A transaction has a date, an item which was bought, and the number of times the item was bought.
- Maximal capacity for each resto.

Example transaction data:

| Resto | Timestamp | Item | Number |
| ----- | --------- | --- | ------: |
| S5    | 3/01/2019 9:17:12 | Chocomousse | 1 |
| S5    | 3/01/2019 9:17:12 | Fruit basis | 1 |

## Existing work

This project is heavily inspired by the work done by Pieter De Clercq and Alexander Van Dyck for their project for the course Data Visualisation, which ~~we stole~~ was very useful. As they were so kind to provide us access to their code, below are the used parts (summarised).

### Interpretation of the data

In particular, they solved the issue of converting the transaction data to a notion of how busy a resto is.

Firstly, transaction with the same timestamp are considered the same person. (TODO: how detailed are the timestamps, e.g. what is the chance of two people having a transaction at the same time).

Secondly, each person is given a duration score, i.e. how long they stay in the resto after they bought something. Purchases are made per category (TODO: is this manual or is the API used.) For example:

    x purchases a soup, a spaghetti and a muffin
    
    Total time:
    base        30 min
    soup        13 min
    main course 27 min
    dessert     1  min
    ------------------
    total       71 min
    
Below is a table detailing the assigned durations  
TODO: check these times and categories

| Type | Duration (min) |
| ----- | ---------: |
| Base | 30 |
| Bread | 7 |
| Soup | 13 |
| Main course | 27 |
| Desserts | 4 |
| Drinks | 1 |
| Fruits | 12 |
| Vegetables | 15 |

Additionally, a probability is assigned to certain types of purchases: the probability the item was a take-away. The take-away chance is 84%, meaning 84% of customers do not count towards the business of the resto. (TODO: again, verify these).

| Type | Takeaway? |
| ----- | --------- |
| Bread | yes |
| Soup | yes |
| Main course | no |
| Desserts | no |
| Drinks | yes |
| Fruits | yes |
| Vegetables | false |

### Prediction

Their project also contains a prediction for the how busy a resto will be. The average of the same day in the last three years is taken. While it might be useful to evaluate, we think a more sophisticated approach yields better results (although this is already a very substantial effort for a data visualisation project).

## Investigated indicators

We believe there are two big factors that influence the popularity of a resto, with the second one being the most influential.

- The menu
- The availability of students nearby

The menu will have an impact, albeit a relatively small one. For example, the majority of the restos only serve Spaghetti Bolognaise once a week. Since this is a relatively popular dish, we expect more students.

With availability of students nearby, we mean two things:

1. The first phenomenon is a relatively stable one: during vacations or other weeks when there are no courses, we expect less students. These periods are often predictable meany years ahead: it is known when vacations are.
2. The second is the class schedule. This can vary a lot between academic years and even between different semesters. For example, if two big faculties in the vicinity of the same resto end their morning course at 11:15, we expect an overcrowding of the resto. If one of the faculties ends at 13:00 however, we can expect only half the number of students.

Both these factors are contained in the date feature.
 
However, since we believe the second factor has a large impact, it is vital that we update the model during the semester. Data from older semesters is still useful for the impact of the menu and of the _timeless_ factors, yet its importance in the predictions should decrease as new data becomes available.
 
### Features

We will use the interpretation described above to process the transactions into the number of people in a resto. This allows us to calculate for every moment how many students are present.
 
Some questions remain:

- In what interval should we calculate this (every minute, every 5, every 10, etc.)?
- How should we model a menu?
    - How would we encode this? One-hot (meaning a different feature per menu item), or some binary encoding (e.g. a bit vector)?  
    -> Currently one-hot with with https://stackoverflow.com/a/51420716.
    - Should/can we include the price? Does the price have an impact on the number of students (e.g. if there is something expensive: does it merely push students to other items or does it decrease the total number). Maybe split into average, min, max prices of the main dishes and include those?  
    -> In a first instance, we will not consider the price.

The data is probably a multivariate time series, which we split per resto. For example:

| Timestamp | Customers | Spaghetti | Tomato soup | ... |
| --------- | --------- | --------- | ----------- | --- |
| 3/01/2019 9:10:00 | 100 | 1 | 0 | ... |

## Models

This is a regression problem. Since output data is numerical and available (number of customers), we prefer supervised learning techniques.

Possibilities are:

- https://en.wikipedia.org/wiki/Vector_autoregression (statistics/economics)
- https://machinelearningmastery.com/how-to-develop-machine-learning-models-for-multivariate-multi-step-air-pollution-time-series-forecasting/ (ML)
- https://blog.exploratory.io/introduction-to-extreme-gradient-boosting-in-exploratory-7bbec554ac7 (ml)
- https://en.wikipedia.org/wiki/Long_short-term_memory (ML)

## Results

None yet.

## Future work

Other indicators we might want to consider:

- Weather (temperature, snow, rain, etc.)
- Pricing of the items on the menu

It might also be worth investigating if inclusion of more explicit date-related data is beneficial, such as events, etc.

## Bibliography

https://machinelearningmastery.com/introduction-to-time-series-forecasting-with-python/

https://pdfs.semanticscholar.org/7277/bc5cda48f949c7728b5c8d71d453f40fc8eb.pdf (no changing menu however)

Introduction to time series and forecasting - ‎Brockwell 

https://ai.stackexchange.com/questions/7781/how-to-model-categorical-variables-enums
