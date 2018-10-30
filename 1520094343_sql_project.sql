/* Welcome to the SQL mini project. For this project, you will use
Springboard' online SQL platform, which you can log into through the
following link:

https://sql.springboard.com/
Username: student
Password: learn_sql@springboard

The data you need is in the "country_club" database. This database
contains 3 tables:
    i) the "Bookings" table,
    ii) the "Facilities" table, and
    iii) the "Members" table.

Note that, if you need to, you can also download these tables locally.

In the mini project, you'll be asked a series of questions. You can
solve them using the platform, but for the final deliverable,
paste the code for each solution into this script, and upload it
to your GitHub.

Before starting with the questions, feel free to take your time,
exploring the data, and getting acquainted with the 3 tables. */



/* Q1: Some of the facilities charge a fee to members, but some do not.
Please list the names of the facilities that do. */

SELECT name 
FROM  country_club.Facilities 
WHERE membercost =0

/* Q2: How many facilities do not charge a fee to members? */

SELECT count(*) as M_Free_Fac_Count
FROM country_club.Facilities
WHERE membercost = 0

/* Q3: How can you produce a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost?
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */

SELECT facid, 
       name as facilityname, 
       membercost, 
       monthlymaintenance 
FROM country_club.Facilities
WHERE membercost < 0.2*monthlymaintenance

/* Q4: How can you retrieve the details of facilities with ID 1 and 5?
Write the query without using the OR operator. */

SELECT *
FROM country_club.Facilities
WHERE facid in (1,5)

/* Q5: How can you produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100? Return the name and monthly maintenance of the facilities
in question. */

SELECT  name, 
        monthlymaintenance,
	CASE WHEN monthlymaintenance <100 THEN 'cheap'
	ELSE 'expensive' END AS cheap_or_expensive
FROM country_club.Facilities


/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Do not use the LIMIT clause for your solution. */

SELECT firstname, 
       surname,
       joindate
FROM country_club.Members
WHERE joindate = (SELECT MAX(joindate) FROM country_club.Members)


/* Q7: How can you produce a list of all members who have used a tennis court?
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */

SELECT Facilities.name as Facility, 
       concat(Members.firstname,' ', Members.surname) AS Member_name
    FROM country_club.Members Members
    LEFT JOIN country_club.Bookings Bookings
      ON Bookings.memid = Members.memid
    LEFT JOIN country_club.Facilities Facilities
      ON Facilities.facid = Bookings.facid
    WHERE Facilities.facid in (0,1)  /* shortlist tennis courts */
    AND Members.memid !=0 /* exclude the guest */
    Group by Member_name

/* Q8: How can you produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30? Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */

SELECT Facilities.name AS Facility,
       concat(Members.firstname,' ', Members.surname) AS Member_name,
       SUM(Bookings.slots * Facilities.membercost) AS Cost
    FROM country_club.Members Members
    JOIN country_club.Bookings Bookings
      ON Bookings.memid = Members.memid
    JOIN country_club.Facilities Facilities
      ON Facilities.facid = Bookings.facid
    WHERE (Bookings.starttime LIKE '2012-09-14%')
    AND Members.memid !=0
    GROUP BY Members.memid
    HAVING Cost >30
    
UNION ALL

SELECT Facilities.name AS Facility,
       Members.surname AS Member_name,
       (Bookings.slots * Facilities.guestcost) AS Cost
    FROM country_club.Members Members
    JOIN country_club.Bookings Bookings
      ON Bookings.memid = Members.memid
    JOIN country_club.Facilities Facilities
      ON Facilities.facid = Bookings.facid
    WHERE (Bookings.starttime LIKE '2012-09-14%')
    AND Members.memid =0
    ORDER BY Cost DESC

/* Q9: This time, produce the same result as in Q8, but using a subquery. */

SELECT B.Facility, M.Member_name, B.Cost
   FROM(
        SELECT name AS Facility, memid, SUM(Bookings.slots * Facilities.membercost) AS Cost
          FROM country_club.Bookings Bookings
          JOIN country_club.Facilities Facilities
            ON Facilities.facid = Bookings.facid
          WHERE Bookings.starttime LIKE '2012-09-14%'
        GROUP BY memid
        ) B
   JOIN (
        SELECT memid, concat(Members.firstname,' ', Members.surname) AS Member_name
          FROM country_club.Members
          WHERE Members.memid !=0 
         ) M
         ON M.memid = B.memid
        HAVING Cost >30

UNION ALL

SELECT B.Facility, M.Member_name, B.Cost
   FROM(
        SELECT name AS Facility, memid, (Bookings.slots * Facilities.guestcost) AS Cost
          FROM country_club.Bookings Bookings
          JOIN country_club.Facilities Facilities
            ON Facilities.facid = Bookings.facid
          WHERE Bookings.starttime LIKE '2012-09-14%'
        ) B
   JOIN (
        SELECT memid, Members.surname AS Member_name
          FROM country_club.Members
          WHERE Members.memid =0 
         ) M
         ON M.memid = B.memid
    ORDER BY Cost DESC


/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */

SELECT Facilities.name as Facility,
       SUM(CASE WHEN Bookings.memid != 0 
           THEN Bookings.slots*Facilities.membercost 
           ELSE Bookings.slots*Facilities.guestcost END
           ) AS Total_revenue
  FROM country_club.Bookings Bookings
  JOIN country_club.Facilities Facilities
    ON Facilities.facid = Bookings.facid
  GROUP BY Facilities.name
  HAVING Total_revenue < 1000
  ORDER BY Total_revenue DESC



