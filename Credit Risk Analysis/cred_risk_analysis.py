import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns

from sklearn.model_selection import train_test_split
from sklearn.metrics import accuracy_score, confusion_matrix
from sklearn.linear_model import LogisticRegression
from sklearn.tree import DecisionTreeClassifier
from sklearn.metrics import precision_score
from sklearn.model_selection import cross_val_score
from sklearn.neighbors import KNeighborsClassifier

desired_width = 320
pd.set_option('display.width', desired_width)
np.set_printoptions(linewidth=desired_width)
pd.set_option('display.max_columns',20)

df = pd.read_csv('clean_dataset.csv')
df = df.drop(['Industry',"BankCustomer", 'Ethnicity',"DriversLicense", 'ZipCode','Gender', 'Citizen'], axis=1)
df["Income"] = df['Income'].replace(0,df['Income'].median())

df_corr = df.corr()
#sns.heatmap(df_corr, annot= True)


##train_test_split
X = df.drop("Approved",axis =1).values
y = df["Approved"].values

X_train, X_test, y_train, y_test = train_test_split(X,y, test_size= 0.80, random_state = 42)

##Decison tree
classifer = DecisionTreeClassifier(criterion= "entropy")
classifer.fit(X_train, y_train)
y_pred = classifer.predict(X_test)
print(accuracy_score(y_test, y_pred))
print(precision_score(y_test, y_pred, average='macro'))

##Cross validation for Decison Tree
scores = cross_val_score(classifer, X, y, cv=5)

mean_accuracy = scores.mean()
std_accuracy = scores.std()
#print(f"Mean Accuracy: {mean_accuracy}")
#print(f"Standard Deviation: {std_accuracy}")

train_acc=[]
test_acc=[]
list_score=[]
p=[]

for i in range (1, 10):
    classifer = DecisionTreeClassifier(max_depth= i, random_state= 0 )
    classifer.fit(X_train, y_train)

    train_pred = classifer.predict(X_train)
    test_pred = classifer.predict(X_test)

    test_acc = accuracy_score(y_test, test_pred)
    train_acc = accuracy_score(y_train, train_pred)
    print(i, "Train score: ", train_acc, 'Test score: ', test_acc)

    list_score.append([i, accuracy_score(train_pred, y_train), accuracy_score(test_pred, y_test)])

df2 = pd.DataFrame(list_score, columns=['Depth', 'Train Accuracy', 'Test Accuracy'])
plt.plot(df2['Depth'], df2['Test Accuracy'], label='Test Accuracy')
plt.plot(df2['Depth'], df2['Train Accuracy'], label='Train Accuracy')
plt.xlabel('Depth')
plt.ylabel('Accuracy')
plt.legend()
#plt.show()
##Use the value of 2 for the model, as it scores 84%
##tree should be allowed to split twice


##Log regression
from sklearn.preprocessing import MinMaxScaler
scaler = MinMaxScaler(feature_range=(0,1))
rescaledXTrain = scaler.fit_transform(X_train)
rescaledXTest = scaler.fit_transform(X_test)

from sklearn.linear_model import LogisticRegression
logreg = LogisticRegression()

logreg.fit(rescaledXTrain, y_train)

from sklearn.metrics import confusion_matrix
y_pred = logreg.predict(rescaledXTest)
y_pred1 = logreg.predict(rescaledXTrain)

# Get the accuracy score of logreg model and print it
print("Test: Accuracy = ", logreg.score(rescaledXTest,y_test))
print("Train: Accuracy = ", logreg.score(rescaledXTrain,y_train))

# Print the confusion matrix of the logreg model
print(confusion_matrix(y_test,y_pred))






