import mysql.connector

print ("Loading VideoGame data")

mydb = mysql.connector.connect(
  user='my_user', #change to your MySQL user
  passwd='my_password',  #change to your MySQL password
  database='testdb',
  host='my_host',   #change to your host
  allow_local_infile=1  #needed so can load local files
)

myc = mydb.cursor()

#reset the variable that allows loading of local files
myc.execute('set global local_infile = 1') 

myc.execute("drop table if exists vg_csv;")

myc.execute("create table vg_csv (ranking TEXT, name TEXT, platform TEXT, year TEXT, genre TEXT, publisher TEXT, na_sales TEXT, eu_sales TEXT, jp_sales TEXT, other_sales TEXT, global_sales TEXT);");


myc.execute("load data local infile 'vgsales.csv' into table vg_csv fields terminated by ',' enclosed by '\"' lines terminated by '\r\n' ignore 1 rows;")
            

print(myc.rowcount, " tuples were inserted")

print("done")

mydb.commit()
mydb.close()

