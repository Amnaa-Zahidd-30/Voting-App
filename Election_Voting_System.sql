REM   Script: Election Voting System
REM   I have joined the code updated the code, created the database, inserted its value implement logic to connect the code.

CREATE TABLE Political_Party ( 
    party_ID NUMBER PRIMARY KEY, 
    party_name VARCHAR2(100) NOT NULL, 
    chairperson_name VARCHAR2(100) NOT NULL, 
    contact_info VARCHAR2(200), 
    headquarters VARCHAR2(200) 
);

CREATE TABLE Candidate ( 
    candidate_ID NUMBER PRIMARY KEY, 
    Name VARCHAR2(100) NOT NULL, 
    date_of_birth DATE NOT NULL, 
    gender VARCHAR2(1) CHECK (gender IN ('M', 'F')), 
religion VARCHAR2 (5) CHECK (religion IN ('Islam','Other')), 
    party_ID NUMBER, 
    FOREIGN KEY (party_ID) REFERENCES Political_Party(party_ID) 
);

CREATE OR REPLACE TRIGGER check_candidate_age 
BEFORE INSERT OR UPDATE ON Candidate 
FOR EACH ROW 
BEGIN 
    IF (TRUNC(MONTHS_BETWEEN(SYSDATE, :NEW.date_of_birth) / 12) < 35) THEN 
        RAISE_APPLICATION_ERROR(-20001, 'Candidate must be at least 35 years old.'); 
    END IF; 
END; 
/

CREATE TABLE Elections ( 
    election_ID NUMBER PRIMARY KEY, 
    election_date DATE NOT NULL, 
    election_type VARCHAR2(50) NOT NULL 
);

CREATE TABLE Provincial_Assembly_Election (  
    pa_election_ID NUMBER PRIMARY KEY,  
    ProvinceName VARCHAR2(100) NOT NULL,  
    total_seats NUMBER NOT NULL  CHECK (total_seats<= 226), 
    total_seats_for_women NUMBER NOT NULL CHECK (total_seats_for_women <= 60), 
    total_seats_for_non_Muslims NUMBER NOT NULL  CHECK (total_seats_for_non_Muslims <= 10), 
    election_ID NUMBER NOT NULL,  
    FOREIGN KEY (election_ID) REFERENCES Elections(election_ID) 
);

CREATE TABLE National_Assembly_Election ( 
    na_election_ID NUMBER PRIMARY KEY, 
    total_seats NUMBER NOT NULL CHECK (total_seats <= 336), 
    total_seats_for_women NUMBER NOT NULL CHECK (total_seats_for_women <= 336), 
    total_seats_for_non_Muslims NUMBER NOT NULL CHECK (total_seats_for_non_Muslims <= 336), 
    election_ID NUMBER NOT NULL, 
    FOREIGN KEY (election_ID) REFERENCES Elections(election_ID) 
);

CREATE TABLE Constituency ( 
    ConstituencyID NUMBER PRIMARY KEY, 
    ConstituencyName VARCHAR2(100) NOT NULL, 
    ProvinceName VARCHAR2(100) NOT NULL 
);

CREATE TABLE Polling_Station ( 
    pollingStationID NUMBER PRIMARY KEY, 
    StationName VARCHAR2(100) NOT NULL, 
    Address VARCHAR2(200) NOT NULL, 
    City VARCHAR2(100) NOT NULL, 
    State VARCHAR2(100) NOT NULL, 
    ZipCode VARCHAR2(20) NOT NULL, 
    ContactNumber VARCHAR2(20) NOT NULL 
);

CREATE TABLE Presiding_Officer ( 
    presidingOfficerID NUMBER PRIMARY KEY, 
    Name VARCHAR2(100) NOT NULL, 
    ContactNumber VARCHAR2(20) NOT NULL, 
    ExperienceYears NUMBER NOT NULL, 
    Address VARCHAR2(200) NOT NULL, 
    PollingStationID NUMBER NOT NULL, 
    FOREIGN KEY (PollingStationID) REFERENCES Polling_Station(pollingStationID) 
);

CREATE TABLE Family ( 
    FamilyID NUMBER PRIMARY KEY, 
    family_member_name VARCHAR2(100) NOT NULL 
);

CREATE TABLE Voter ( 
    VoterID NUMBER PRIMARY KEY, 
    City VARCHAR2(100) NOT NULL, 
    Gender VARCHAR2(1) CHECK (Gender IN ('M', 'F')), 
    State VARCHAR2(100) NOT NULL, 
    Email VARCHAR2(100) NOT NULL, 
    Name VARCHAR2(100) NOT NULL, 
    CNIC VARCHAR2(15) UNIQUE NOT NULL, 
    DateOfBirth DATE NOT NULL, 
    family_ID NUMBER, 
    FOREIGN KEY (family_ID) REFERENCES Family(FamilyID) 
);

CREATE OR REPLACE TRIGGER check_voter_age 
BEFORE INSERT OR UPDATE ON Voter 
FOR EACH ROW 
BEGIN 
    IF (TRUNC(MONTHS_BETWEEN(SYSDATE, :NEW.DateOfBirth) / 12) < 18) THEN 
        RAISE_APPLICATION_ERROR(-20002, 'Voter must be at least 18 years old.'); 
    END IF; 
END; 
/

CREATE TABLE Family_Member_Record( 
	MemberID NUMBER PRIMARY KEY, 
    Gender VARCHAR2(1) CHECK (Gender IN ('M', 'F')), 
    CNIC VARCHAR2(15) UNIQUE NOT NULL, 
    DateOfBirth DATE NOT NULL, 
    family_ID NUMBER, 
    Voter_ID NUMBER, 
    FOREIGN KEY (family_ID) REFERENCES Family(FamilyID), 
    FOREIGN KEY (Voter_ID) REFERENCES Voter(VoterID) 
);

CREATE OR REPLACE TRIGGER check_family_member_age  
BEFORE INSERT OR UPDATE ON Family_Member_Record  
FOR EACH ROW  
BEGIN  
    IF (TRUNC(MONTHS_BETWEEN(SYSDATE, :NEW.DateOfBirth) / 12) < 18) THEN  
        RAISE_APPLICATION_ERROR(-20002, 'Voter must be at least 18 years old.');  
    END IF;  
END; 
/

CREATE TABLE Vote ( 
    VoteID NUMBER PRIMARY KEY, 
    VoterID NUMBER NOT NULL, 
    ConstituencyID NUMBER NOT NULL, 
    PollingStationID NUMBER NOT NULL, 
    ElectionID NUMBER NOT NULL, 
    CandidateID NUMBER NOT NULL, 
    Verified VARCHAR2(3) CHECK (Verified IN ('Yes', 'No')) NOT NULL, 
    VoteType VARCHAR2(50) NOT NULL, 
    VoteDateTime TIMESTAMP NOT NULL, 
    FOREIGN KEY (VoterID) REFERENCES Voter(VoterID), 
    FOREIGN KEY (ConstituencyID) REFERENCES Constituency(ConstituencyID), 
    FOREIGN KEY (PollingStationID) REFERENCES Polling_Station(pollingStationID), 
    FOREIGN KEY (ElectionID) REFERENCES Elections(election_ID), 
    FOREIGN KEY (CandidateID) REFERENCES Candidate(candidate_ID) 
);

CREATE TABLE Returning_Officer ( 
    returningOfficerID NUMBER PRIMARY KEY, 
    Name VARCHAR2(100) NOT NULL, 
    Email VARCHAR2(100) NOT NULL, 
    ContactNumber VARCHAR2(20) NOT NULL, 
    ConstituencyID NUMBER NOT NULL, 
    FOREIGN KEY (ConstituencyID) REFERENCES Constituency(ConstituencyID) 
);

CREATE TABLE Polling_Station_Result ( 
    PollingStationResultID NUMBER PRIMARY KEY, 
    ConstituencyID NUMBER NOT NULL, 
    CandidateName VARCHAR2(100) NOT NULL, 
    CandidateID NUMBER NOT NULL, 
    ElectionID NUMBER NOT NULL, 
    VotesReceived NUMBER, 
    FOREIGN KEY (ConstituencyID) REFERENCES Constituency(ConstituencyID), 
    FOREIGN KEY (CandidateID) REFERENCES Candidate(candidate_ID), 
    FOREIGN KEY (ElectionID) REFERENCES Elections(election_ID) 
);

CREATE TABLE Province_Assembly_Result ( 
    PA_ResultID NUMBER PRIMARY KEY, 
    ProvinceID NUMBER NOT NULL, 
    ConstituencyID NUMBER NOT NULL, 
    CandidateName VARCHAR2(100) NOT NULL, 
    CandidateID NUMBER NOT NULL, 
    VotesReceived NUMBER, 
    ResultStatus VARCHAR2(50), 
    FOREIGN KEY (ConstituencyID) REFERENCES Constituency(ConstituencyID), 
    FOREIGN KEY (CandidateID) REFERENCES Candidate(candidate_ID) 
);

CREATE TABLE National_Assembly_Result ( 
    NA_ResultID NUMBER PRIMARY KEY, 
    TotalPollingStations NUMBER NOT NULL, 
    VotesReceived NUMBER, 
    ResultStatus VARCHAR2(50), 
    ConstituencyID NUMBER NOT NULL, 
    CandidateName VARCHAR2(100) NOT NULL, 
    CandidateID NUMBER NOT NULL, 
    FOREIGN KEY (ConstituencyID) REFERENCES Constituency(ConstituencyID), 
    FOREIGN KEY (CandidateID) REFERENCES Candidate(candidate_ID) 
);

CREATE TABLE Elected_Official ( 
    ElectedOfficialID NUMBER PRIMARY KEY, 
    PartyID NUMBER NOT NULL, 
    ConstituencyID NUMBER NOT NULL, 
    VotesReceived NUMBER NOT NULL, 
    ElectedOfficialName VARCHAR2(100) NOT NULL, 
    TermStart DATE, 
    TermEnd DATE, 
    FOREIGN KEY (PartyID) REFERENCES Political_Party(party_ID), 
    FOREIGN KEY (ConstituencyID) REFERENCES Constituency(ConstituencyID) 
);

CREATE OR REPLACE TRIGGER check_family_member_age  
BEFORE INSERT OR UPDATE ON Family_Member_Record  
FOR EACH ROW  
BEGIN  
    IF (TRUNC(MONTHS_BETWEEN(SYSDATE, :NEW.DateOfBirth) / 12) < 18) THEN  
        RAISE_APPLICATION_ERROR(-20002, 'Voter must be at least 18 years old.');  
    END IF;  
END; 
/

INSERT INTO Political_Party (party_ID, party_name, chairperson_name, contact_info, headquarters) 
VALUES (1, 'Pakistan Demoratic Party', 'Ali Khan', 'info@pdp.org.pk', 'Islamabad');

INSERT INTO Political_Party (party_ID, party_name, chairperson_name, contact_info, headquarters) 
VALUES (2, 'Freedom Party of Pakistan', 'Sarah Ahmed', 'info@fpp.org.pk', 'Islamabad');

INSERT INTO Political_Party (party_ID, party_name, chairperson_name, contact_info, headquarters) 
VALUES (3, 'Unity Movement Pakistan', 'Aamir Ahmed', 'info@ump.org.pk', 'Lahore');

INSERT INTO Political_Party (party_ID, party_name, chairperson_name, contact_info, headquarters) 
VALUES (4, 'Progressive Front Pakistan', 'Sana Ali', 'info@pfp.org.pk', 'Karachi');

INSERT INTO Political_Party (party_ID, party_name, chairperson_name, contact_info, headquarters) 
VALUES (5, 'Peace and Prosperity Party', 'Zayn Malik', 'info@peaceparty.org.pk', 'Rawalpindi');

INSERT INTO Political_Party (party_ID, party_name, chairperson_name, contact_info, headquarters) 
VALUES (6, 'Justice Party of Pakistan', 'Nadia Shah', 'info@justiceparty.org.pk', 'Peshawar');

INSERT INTO Political_Party (party_ID, party_name, chairperson_name, contact_info, headquarters) 
VALUES (7, 'Harmony Pakistan Movement', 'Ali Raza', 'info@harmonypak.org.pk', 'Quetta');

INSERT INTO Political_Party (party_ID, party_name, chairperson_name, contact_info, headquarters) 
VALUES (8, 'Future Vision Party', 'Ayesha Shaikh', 'info@fvp.org.pk', 'Gujranwala');

INSERT INTO Political_Party (party_ID, party_name, chairperson_name, contact_info, headquarters) 
VALUES (9, 'Prosperous Pakistan League', 'Hamza Ali', 'info@prosperouspakistan.org.pk', 'Multan');

INSERT INTO Political_Party (party_ID, party_name, chairperson_name, contact_info, headquarters) 
VALUES (10, 'New Horizon Movement', 'Fatima Abbas', 'info@newhorizon.org.pk', 'Faisalabad');

INSERT INTO Political_Party (party_ID, party_name, chairperson_name, contact_info, headquarters) 
VALUES (11, 'Progressive Pakistan Alliance', 'Ahmed Khan', 'info@ppa.org.pk', 'Hyderabad');

SELECT * FROM Political_Party;

INSERT INTO Political_Party (party_ID, party_name, chairperson_name, contact_info, headquarters) 
VALUES (12, 'Renaissance Party of Pakistan', 'Haidar Abbas', 'info@rpp.org.pk', 'Islamabad');

INSERT INTO Political_Party (party_ID, party_name, chairperson_name, contact_info, headquarters) 
VALUES (13, 'Harmony for Unity Party', 'Sara Khan', 'info@hup.org.pk', 'Lahore');

INSERT INTO Political_Party (party_ID, party_name, chairperson_name, contact_info, headquarters) 
VALUES (14, 'Liberty and Justice Movement', 'Kamran Malik', 'info@ljm.org.pk', 'Karachi');

INSERT INTO Political_Party (party_ID, party_name, chairperson_name, contact_info, headquarters) 
VALUES (15, 'Progressive Democratic Alliance', 'Sadia Ahmed', 'info@pda.org.pk', 'Rawalpindi');

SELECT * FROM Political_Party;

UPDATE Political_Party 
SET party_name = 'Pakistan Democratic Party' 
WHERE party_ID = 1;

SELECT * FROM Political_Party;

INSERT INTO Candidate (candidate_ID, Name, date_of_birth, gender, religion, party_ID) 
VALUES (101, 'Ali Hassan', TO_DATE('1985-09-15', 'YYYY-MM-DD'), 'M', 'Islam', 1);

INSERT INTO Candidate (candidate_ID, Name, date_of_birth, gender, religion, party_ID) 
VALUES (102, 'Saba Ahmed', TO_DATE('1990-03-25', 'YYYY-MM-DD'), 'F', 'Islam', 2);

INSERT INTO Candidate (candidate_ID, Name, date_of_birth, gender, religion, party_ID) 
VALUES (103, 'Ahmed Khan', TO_DATE('1982-11-10', 'YYYY-MM-DD'), 'M', 'Islam', 3);

INSERT INTO Candidate (candidate_ID, Name, date_of_birth, gender, religion, party_ID) 
VALUES (104, 'Sana Malik', TO_DATE('1988-07-02', 'YYYY-MM-DD'), 'F', 'Islam', 4);

INSERT INTO Candidate (candidate_ID, Name, date_of_birth, gender, religion, party_ID) 
VALUES (105, 'Charles Leclerc', TO_DATE('1987-12-20', 'YYYY-MM-DD'), 'M', 'Other', 5);

INSERT INTO Candidate (candidate_ID, Name, date_of_birth, gender, religion, party_ID) 
VALUES (106, 'Nadir Khan', TO_DATE('1984-04-18', 'YYYY-MM-DD'), 'M', 'Islam', 6);

INSERT INTO Candidate (candidate_ID, Name, date_of_birth, gender, religion, party_ID) 
VALUES (107, 'Ayesha Raza', TO_DATE('1989-06-30', 'YYYY-MM-DD'), 'F', 'Islam', 7);

INSERT INTO Candidate (candidate_ID, Name, date_of_birth, gender, religion, party_ID) 
VALUES (108, 'Hamza Ali', TO_DATE('1983-01-05', 'YYYY-MM-DD'), 'M', 'Islam', 8);

INSERT INTO Candidate (candidate_ID, Name, date_of_birth, gender, religion, party_ID) 
VALUES (109, 'Fahad Abbas', TO_DATE('1986-08-12', 'YYYY-MM-DD'), 'M', 'Islam', 9);

INSERT INTO Candidate (candidate_ID, Name, date_of_birth, gender, religion, party_ID) 
VALUES (110, 'Fatima Akhtar', TO_DATE('1991-02-28', 'YYYY-MM-DD'), 'F', 'Islam', 10);

INSERT INTO Candidate (candidate_ID, Name, date_of_birth, gender, religion, party_ID) 
VALUES (111, 'Ahmed Malik', TO_DATE('1980-12-10', 'YYYY-MM-DD'), 'M', 'Islam', 11);

INSERT INTO Candidate (candidate_ID, Name, date_of_birth, gender, religion, party_ID) 
VALUES (112, 'Hassan Ali', TO_DATE('1987-05-20', 'YYYY-MM-DD'), 'M', 'Islam', 12);

INSERT INTO Candidate (candidate_ID, Name, date_of_birth, gender, religion, party_ID) 
VALUES (113, 'Alexa', TO_DATE('1984-09-08', 'YYYY-MM-DD'), 'F', 'Other', 13);

INSERT INTO Candidate (candidate_ID, Name, date_of_birth, gender, religion, party_ID) 
VALUES (114, 'Kamran Ali', TO_DATE('1985-11-15', 'YYYY-MM-DD'), 'M', 'Islam', 14);

INSERT INTO Candidate (candidate_ID, Name, date_of_birth, gender, religion, party_ID) 
VALUES (115, 'Sadia Ahmed', TO_DATE('1983-03-12', 'YYYY-MM-DD'), 'F', 'Islam', 15);

INSERT INTO Candidate (candidate_ID, Name, date_of_birth, gender, religion, party_ID) 
VALUES (110, 'Fatima Akhtar', TO_DATE('1989-02-28', 'YYYY-MM-DD'), 'F', 'Islam', 10);

SELECT * FROM Candidate;

INSERT INTO Candidate (candidate_ID, Name, date_of_birth, gender, religion, party_ID) 
VALUES (102, 'Saba Ahmed', TO_DATE('1985-03-25', 'YYYY-MM-DD'), 'F', 'Islam', 2);

INSERT INTO Candidate (candidate_ID, Name, date_of_birth, gender, religion, party_ID) 
VALUES (107, 'Ayesha Raza', TO_DATE('1983-06-30', 'YYYY-MM-DD'), 'F', 'Islam', 7);

SELECT * FROM Candidate;

SELECT * FROM Elections;

INSERT INTO Elections (election_ID, election_date, election_type) 
VALUES (24, TO_DATE('2024-07-20', 'YYYY-MM-DD'), 'General');

INSERT INTO Elections (election_ID, election_date, election_type) 
VALUES (18, TO_DATE('2018-11-15', 'YYYY-MM-DD'), 'General');

INSERT INTO Elections (election_ID, election_date, election_type) 
VALUES (13, TO_DATE('2013-11-15', 'YYYY-MM-DD'), 'General');

INSERT INTO Elections (election_ID, election_date, election_type) 
VALUES (08, TO_DATE('2008-11-15', 'YYYY-MM-DD'), 'General');

INSERT INTO Elections (election_ID, election_date, election_type) 
VALUES (02, TO_DATE('2002-11-15', 'YYYY-MM-DD'), 'General');

INSERT INTO Elections (election_ID, election_date, election_type) 
VALUES (97, TO_DATE('1997-11-15', 'YYYY-MM-DD'), 'General');

INSERT INTO Elections (election_ID, election_date, election_type) 
VALUES (93, TO_DATE('1993-11-15', 'YYYY-MM-DD'), 'General');

INSERT INTO Elections (election_ID, election_date, election_type) 
VALUES (90, TO_DATE('1990-11-15', 'YYYY-MM-DD'), 'General');

INSERT INTO Elections (election_ID, election_date, election_type) 
VALUES (88, TO_DATE('1988-11-15', 'YYYY-MM-DD'), 'General');

INSERT INTO Elections (election_ID, election_date, election_type) 
VALUES (85, TO_DATE('1985-11-15', 'YYYY-MM-DD'), 'General');

INSERT INTO Elections (election_ID, election_date, election_type) 
VALUES (77, TO_DATE('1977-11-15', 'YYYY-MM-DD'), 'General');

INSERT INTO Elections (election_ID, election_date, election_type) 
VALUES (70, TO_DATE('1970-11-15', 'YYYY-MM-DD'), 'General');

INSERT INTO Elections (election_ID, election_date, election_type) 
VALUES (62, TO_DATE('1962-11-15', 'YYYY-MM-DD'), 'General');

INSERT INTO Elections (election_ID, election_date, election_type) 
VALUES (54, TO_DATE('1954-11-15', 'YYYY-MM-DD'), 'General');

SELECT * FROM Elections;

INSERT INTO Provincial_Assembly_Election (pa_election_ID, ProvinceName, total_seats, total_seats_for_women, total_seats_for_non_Muslims, election_ID) 
VALUES (2, 'Sindh', 130, 29, 9, 24);

INSERT INTO Provincial_Assembly_Election (pa_election_ID, ProvinceName, total_seats, total_seats_for_women, total_seats_for_non_Muslims, election_ID) 
VALUES (3, 'Khyber Pakhtunkhwa', 115, 26, 4, 24);

INSERT INTO Provincial_Assembly_Election (pa_election_ID, ProvinceName, total_seats, total_seats_for_women, total_seats_for_non_Muslims, election_ID) 
VALUES (4, 'Balochistan', 51, 11, 3, 24);

SELECT * FROM Provincial_Assembly_Election;

INSERT INTO Provincial_Assembly_Election (pa_election_ID, ProvinceName, total_seats, total_seats_for_women, total_seats_for_non_Muslims, election_ID) 
VALUES (1, 'Punjab', 226, 60,8 , 24);

SELECT * FROM Provincial_Assembly_Election;

INSERT INTO National_Assembly_Election (na_election_ID, total_seats, total_seats_for_women, total_seats_for_non_Muslims, election_ID) 
VALUES (1, 266, 60, 10, 24);

SELECT * FROM National_Assembly_Election;

INSERT INTO Constituency (ConstituencyID, ConstituencyName, ProvinceName) 
VALUES (1, 'Karachi South', 'Sindh');

INSERT INTO Constituency (ConstituencyID, ConstituencyName, ProvinceName) 
VALUES (2, 'Karachi North', 'Sindh');

INSERT INTO Constituency (ConstituencyID, ConstituencyName, ProvinceName) 
VALUES (3, 'Karachi Central', 'Sindh');

INSERT INTO Constituency (ConstituencyID, ConstituencyName, ProvinceName) 
VALUES (4, 'Karachi West', 'Sindh');

INSERT INTO Constituency (ConstituencyID, ConstituencyName, ProvinceName) 
VALUES (5, 'Karachi East', 'Sindh');

INSERT INTO Constituency (ConstituencyID, ConstituencyName, ProvinceName) 
VALUES (6, 'Lahore South', 'Punjab');

INSERT INTO Constituency (ConstituencyID, ConstituencyName, ProvinceName) 
VALUES (7, 'Lahore North', 'Punjab');

INSERT INTO Constituency (ConstituencyID, ConstituencyName, ProvinceName) 
VALUES (8, 'Lahore Central', 'Punjab');

INSERT INTO Constituency (ConstituencyID, ConstituencyName, ProvinceName) 
VALUES (9, 'Lahore West', 'Punjab');

INSERT INTO Constituency (ConstituencyID, ConstituencyName, ProvinceName) 
VALUES (10, 'Lahore East', 'Punjab');

INSERT INTO Constituency (ConstituencyID, ConstituencyName, ProvinceName) 
VALUES (7, 'Quetta South', 'Balochistan');

INSERT INTO Constituency (ConstituencyID, ConstituencyName, ProvinceName) 
VALUES (11, 'Quetta East', 'Balochistan');

INSERT INTO Constituency (ConstituencyID, ConstituencyName, ProvinceName) 
VALUES (12, 'Peshawar South', 'Khyber Pakhtunkhwa');

INSERT INTO Constituency (ConstituencyID, ConstituencyName, ProvinceName) 
VALUES (13, 'Peshawar North', 'Khyber Pakhtunkhwa');

INSERT INTO Constituency (ConstituencyID, ConstituencyName, ProvinceName) 
VALUES (14, 'Peshawar Central', 'Khyber Pakhtunkhwa');

INSERT INTO Constituency (ConstituencyID, ConstituencyName, ProvinceName) 
VALUES (15, 'Peshawar West', 'Khyber Pakhtunkhwa');

INSERT INTO Constituency (ConstituencyID, ConstituencyName, ProvinceName) 
VALUES (16, 'Peshawar East', 'Khyber Pakhtunkhwa');

INSERT INTO Constituency (ConstituencyID, ConstituencyName, ProvinceName) 
VALUES (17, 'Islamabad Federal', 'Federal');

SELECT * FROM Constituency;

SELECT * FROM Political_Party;

SELECT * FROM Constituency;

INSERT INTO Polling_Station (pollingStationID, StationName, Address, City, State, ZipCode, ContactNumber) 
VALUES (1, 'KHI-PS-1', '123 Main Street, Clifton', 'Karachi', 'Sindh', '12345', '03001234567');

INSERT INTO Polling_Station (pollingStationID, StationName, Address, City, State, ZipCode, ContactNumber) 
VALUES (2, 'KHI-PS-2', '456 Park Avenue, Saddar', 'Karachi', 'Sindh', '23456', '03002345678');

INSERT INTO Polling_Station (pollingStationID, StationName, Address, City, State, ZipCode, ContactNumber) 
VALUES (3, 'KHI-PS-3', '789 Beach Road, Clifton Beach', 'Karachi', 'Sindh', '34567', '03003456789');

INSERT INTO Polling_Station (pollingStationID, StationName, Address, City, State, ZipCode, ContactNumber) 
VALUES (4, 'KHI-PS-4', '1010 Business Center, North Nazimabad', 'Karachi', 'Sindh', '45678', '03004567890');

INSERT INTO Polling_Station (pollingStationID, StationName, Address, City, State, ZipCode, ContactNumber) 
VALUES (5, 'KHI-PS-5', '111 Central Plaza, Gulshan-e-Iqbal', 'Karachi', 'Sindh', '56789', '03005678901');

INSERT INTO Polling_Station (pollingStationID, StationName, Address, City, State, ZipCode, ContactNumber) 
VALUES (6, 'KHI-PS-6', '1212 Downtown Mall, PECHS', 'Karachi', 'Sindh', '67890', '03006789012');

INSERT INTO Polling_Station (pollingStationID, StationName, Address, City, State, ZipCode, ContactNumber) 
VALUES (7, 'KHI-PS-7', '1313 Liberty Market, Clifton', 'Karachi', 'Sindh', '78901', '03007890123');

INSERT INTO Polling_Station (pollingStationID, StationName, Address, City, State, ZipCode, ContactNumber) 
VALUES (8, 'KHI-PS-8', '1414 West End Avenue, Defence', 'Karachi', 'Sindh', '89012', '03008901234');

INSERT INTO Polling_Station (pollingStationID, StationName, Address, City, State, ZipCode, ContactNumber) 
VALUES (9, 'KHI-PS-9', '1515 Beach View Road, Clifton', 'Karachi', 'Sindh', '90123', '03009012345');

INSERT INTO Polling_Station (pollingStationID, StationName, Address, City, State, ZipCode, ContactNumber) 
VALUES (10, 'KHI-PS-10', '1616 City Towers, Gulshan-e-Iqbal', 'Karachi', 'Sindh', '01234', '03000123456');

INSERT INTO Polling_Station (pollingStationID, StationName, Address, City, State, ZipCode, ContactNumber) 
VALUES (51, 'LHR-PS-11', '1717 Southern Plaza, DHA', 'Lahore', 'Punjab', '12345', '03001234567');

INSERT INTO Polling_Station (pollingStationID, StationName, Address, City, State, ZipCode, ContactNumber) 
VALUES (52, 'LHR-PS-12', '1818 Liberty Market, Gulberg', 'Lahore', 'Punjab', '23456', '03002345678');

INSERT INTO Polling_Station (pollingStationID, StationName, Address, City, State, ZipCode, ContactNumber) 
VALUES (53, 'LHR-PS-13', '1919 Northern Avenue, Model Town', 'Lahore', 'Punjab', '34567', '03003456789');

INSERT INTO Polling_Station (pollingStationID, StationName, Address, City, State, ZipCode, ContactNumber) 
VALUES (54, 'LHR-PS-14', '2020 Garden Town Plaza, Garden Town', 'Lahore', 'Punjab', '45678', '03004567890');

INSERT INTO Polling_Station (pollingStationID, StationName, Address, City, State, ZipCode, ContactNumber) 
VALUES (55, 'LHR-PS-15', '2121 Central Market, Model Town', 'Lahore', 'Punjab', '56789', '03005678901');

INSERT INTO Polling_Station (pollingStationID, StationName, Address, City, State, ZipCode, ContactNumber) 
VALUES (56, 'LHR-PS-16', '2222 Mall Road Plaza, Mall Road', 'Lahore', 'Punjab', '67890', '03006789012');

INSERT INTO Polling_Station (pollingStationID, StationName, Address, City, State, ZipCode, ContactNumber) 
VALUES (57, 'LHR-PS-17', '2323 West End Avenue, Gulberg', 'Lahore', 'Punjab', '78901', '03007890123');

INSERT INTO Polling_Station (pollingStationID, StationName, Address, City, State, ZipCode, ContactNumber) 
VALUES (58, 'LHR-PS-18', '2424 Downtown Mall, Defence', 'Lahore', 'Punjab', '89012', '03008901234');

INSERT INTO Polling_Station (pollingStationID, StationName, Address, City, State, ZipCode, ContactNumber) 
VALUES (59, 'LHR-PS-19', '2525 East Street, Garden Town', 'Lahore', 'Punjab', '90123', '03009012345');

INSERT INTO Polling_Station (pollingStationID, StationName, Address, City, State, ZipCode, ContactNumber) 
VALUES (60, 'LHR-PS-20', '2626 City Towers, Model Town', 'Lahore', 'Punjab', '01234', '03000123456');

INSERT INTO Polling_Station (pollingStationID, StationName, Address, City, State, ZipCode, ContactNumber) 
VALUES (101, 'QUETTA-PS-21', '2727 East Street, Quetta East', 'Quetta', 'Balochistan', '12345', '03001234567');

INSERT INTO Polling_Station (pollingStationID, StationName, Address, City, State, ZipCode, ContactNumber) 
VALUES (102, 'QUETTA-PS-22', '2828 West End Avenue, Quetta West', 'Quetta', 'Balochistan', '23456', '03002345678');

INSERT INTO Polling_Station (pollingStationID, StationName, Address, City, State, ZipCode, ContactNumber) 
VALUES (151, 'PESH-PS-23', '2929 South Plaza, Peshawar South', 'Peshawar', 'Khyber Pakhtunkhwa', '34567', '03003456789');

INSERT INTO Polling_Station (pollingStationID, StationName, Address, City, State, ZipCode, ContactNumber) 
VALUES (152, 'PESH-PS-24', '3030 Central Market, Peshawar City', 'Peshawar', 'Khyber Pakhtunkhwa', '45678', '03004567890');

INSERT INTO Polling_Station (pollingStationID, StationName, Address, City, State, ZipCode, ContactNumber) 
VALUES (201, 'PESH-PS-25', '3131 Northern Avenue, Peshawar North', 'Peshawar', 'Khyber Pakhtunkhwa', '56789', '03005678901');

INSERT INTO Polling_Station (pollingStationID, StationName, Address, City, State, ZipCode, ContactNumber) 
VALUES (202, 'PESH-PS-26', '3232 Garden Town Plaza, Peshawar Cantt', 'Peshawar', 'Khyber Pakhtunkhwa', '67890', '03006789012');

INSERT INTO Polling_Station (pollingStationID, StationName, Address, City, State, ZipCode, ContactNumber) 
VALUES (251, 'PESH-PS-27', '3333 Central Plaza, Peshawar Central', 'Peshawar', 'Khyber Pakhtunkhwa', '78901', '03007890123');

INSERT INTO Polling_Station (pollingStationID, StationName, Address, City, State, ZipCode, ContactNumber) 
VALUES (252, 'PESH-PS-28', '3434 Mall Road Plaza, University Road', 'Peshawar', 'Khyber Pakhtunkhwa', '89012', '03008901234');

INSERT INTO Polling_Station (pollingStationID, StationName, Address, City, State, ZipCode, ContactNumber) 
VALUES (301, 'PESH-PS-29', '3535 West End Avenue, Peshawar West', 'Peshawar', 'Khyber Pakhtunkhwa', '90123', '03009012345');

INSERT INTO Polling_Station (pollingStationID, StationName, Address, City, State, ZipCode, ContactNumber) 
VALUES (302, 'PESH-PS-30', '3636 Downtown Mall, Hayatabad', 'Peshawar', 'Khyber Pakhtunkhwa', '01234', '03000123456');

INSERT INTO Polling_Station (pollingStationID, StationName, Address, City, State, ZipCode, ContactNumber) 
VALUES (351, 'PESH-PS-31', '3737 East Street, University Town', 'Peshawar', 'Khyber Pakhtunkhwa', '12345', '03001234567');

INSERT INTO Polling_Station (pollingStationID, StationName, Address, City, State, ZipCode, ContactNumber) 
VALUES (352, 'PESH-PS-32', '3838 City Towers, Cantt Area', 'Peshawar', 'Khyber Pakhtunkhwa', '23456', '03002345678');

INSERT INTO Polling_Station (pollingStationID, StationName, Address, City, State, ZipCode, ContactNumber) 
VALUES (401, 'ISL-PS-33', '3939 Federal Plaza, Blue Area', 'Islamabad', 'Federal', '34567', '03003456789');

INSERT INTO Polling_Station (pollingStationID, StationName, Address, City, State, ZipCode, ContactNumber) 
VALUES (402, 'ISL-PS-34', '4040 Parliament Road, G-5', 'Islamabad', 'Federal', '45678', '03004567890');

INSERT INTO Presiding_Officer (presidingOfficerID, Name, ContactNumber, ExperienceYears, Address, PollingStationID) 
VALUES (1, 'Ali Khan', '03001234567', 5, '1-A Main Street, Clifton, Karachi', 1);

INSERT INTO Presiding_Officer (presidingOfficerID, Name, ContactNumber, ExperienceYears, Address, PollingStationID) 
VALUES (2, 'Sana Ahmed', '03002345678', 3, '2-B Park Avenue, Saddar, Karachi', 2);

INSERT INTO Presiding_Officer (presidingOfficerID, Name, ContactNumber, ExperienceYears, Address, PollingStationID) 
VALUES (3, 'Ahmed Malik', '03003456789', 4, '3-C Beach Road, Clifton Beach, Karachi', 3);

INSERT INTO Presiding_Officer (presidingOfficerID, Name, ContactNumber, ExperienceYears, Address, PollingStationID) 
VALUES (4, 'Farah Khan', '03004567890', 2, '4-D Business Center, North Nazimabad, Karachi', 4);

INSERT INTO Presiding_Officer (presidingOfficerID, Name, ContactNumber, ExperienceYears, Address, PollingStationID) 
VALUES (5, 'Usman Ali', '03005678901', 6, '5-E Central Plaza, Gulshan-e-Iqbal, Karachi', 5);

INSERT INTO Presiding_Officer (presidingOfficerID, Name, ContactNumber, ExperienceYears, Address, PollingStationID) 
VALUES (6, 'Ayesha Siddiqui', '03006789012', 1, '6-F Downtown Mall, PECHS, Karachi', 6);

INSERT INTO Presiding_Officer (presidingOfficerID, Name, ContactNumber, ExperienceYears, Address, PollingStationID) 
VALUES (7, 'Bilal Khan', '03007890123', 3, '7-G Liberty Market, Clifton, Karachi', 7);

INSERT INTO Presiding_Officer (presidingOfficerID, Name, ContactNumber, ExperienceYears, Address, PollingStationID) 
VALUES (8, 'Sadia Aslam', '03008901234', 2, '8-H West End Avenue, Defence, Karachi', 8);

INSERT INTO Presiding_Officer (presidingOfficerID, Name, ContactNumber, ExperienceYears, Address, PollingStationID) 
VALUES (9, 'Rizwan Ahmed', '03009012345', 4, '9-I Beach View Road, Clifton, Karachi', 9);

INSERT INTO Presiding_Officer (presidingOfficerID, Name, ContactNumber, ExperienceYears, Address, PollingStationID) 
VALUES (10, 'Fariha Khan', '03000123456', 3, '10-J City Towers, Gulshan-e-Iqbal, Karachi', 10);

INSERT INTO Presiding_Officer (presidingOfficerID, Name, ContactNumber, ExperienceYears, Address, PollingStationID) 
VALUES (11, 'Asad Mahmood', '03001234567', 5, '11-K Southern Plaza, DHA, Lahore', 51);

INSERT INTO Presiding_Officer (presidingOfficerID, Name, ContactNumber, ExperienceYears, Address, PollingStationID) 
VALUES (12, 'Saima Batool', '03002345678', 3, '12-L Liberty Market, Gulberg, Lahore', 52);

INSERT INTO Presiding_Officer (presidingOfficerID, Name, ContactNumber, ExperienceYears, Address, PollingStationID) 
VALUES (13, 'Kamran Ali', '03003456789', 4, '13-M Northern Avenue, Model Town, Lahore', 53);

INSERT INTO Presiding_Officer (presidingOfficerID, Name, ContactNumber, ExperienceYears, Address, PollingStationID) 
VALUES (14, 'Ayesha Malik', '03004567890', 2, '14-N Garden Town Plaza, Garden Town, Lahore', 54);

INSERT INTO Presiding_Officer (presidingOfficerID, Name, ContactNumber, ExperienceYears, Address, PollingStationID) 
VALUES (15, 'Imran Ahmed', '03005678901', 6, '15-O Central Market, Model Town, Lahore', 55);

INSERT INTO Presiding_Officer (presidingOfficerID, Name, ContactNumber, ExperienceYears, Address, PollingStationID) 
VALUES (16, 'Zoya Khan', '03006789012', 1, '16-P Mall Road Plaza, Mall Road, Lahore', 56);

INSERT INTO Presiding_Officer (presidingOfficerID, Name, ContactNumber, ExperienceYears, Address, PollingStationID) 
VALUES (17, 'Ahmed Shahzad', '03007890123', 3, '17-Q West End Avenue, Gulberg, Lahore', 57);

INSERT INTO Presiding_Officer (presidingOfficerID, Name, ContactNumber, ExperienceYears, Address, PollingStationID) 
VALUES (18, 'Sadia Khan', '03008901234', 2, '18-R Downtown Mall, Defence, Lahore', 58);

INSERT INTO Presiding_Officer (presidingOfficerID, Name, ContactNumber, ExperienceYears, Address, PollingStationID) 
VALUES (19, 'Bilal Ahmed', '03009012345', 4, '19-S East Street, Garden Town, Lahore', 59);

INSERT INTO Presiding_Officer (presidingOfficerID, Name, ContactNumber, ExperienceYears, Address, PollingStationID) 
VALUES (20, 'Maryam Fatima', '03000123456', 3, '20-T City Towers, Model Town, Lahore', 60);

INSERT INTO Presiding_Officer (presidingOfficerID, Name, ContactNumber, ExperienceYears, Address, PollingStationID) 
VALUES (21, 'Ali Khan', '03001234567', 5, '21-U East Street, Quetta East', 101);

INSERT INTO Presiding_Officer (presidingOfficerID, Name, ContactNumber, ExperienceYears, Address, PollingStationID) 
VALUES (22, 'Sana Ahmed', '03002345678', 3, '22-V West End Avenue, Quetta West', 102);

INSERT INTO Presiding_Officer (presidingOfficerID, Name, ContactNumber, ExperienceYears, Address, PollingStationID) 
VALUES (23, 'Ahmed Malik', '03003456789', 4, '23-W South Plaza, Peshawar South', 151);

INSERT INTO Presiding_Officer (presidingOfficerID, Name, ContactNumber, ExperienceYears, Address, PollingStationID) 
VALUES (24, 'Farah Khan', '03004567890', 2, '24-X Central Market, Peshawar City', 152);

INSERT INTO Presiding_Officer (presidingOfficerID, Name, ContactNumber, ExperienceYears, Address, PollingStationID) 
VALUES (25, 'Usman Ali', '03005678901', 6, '25-Y Northern Avenue, Peshawar North', 201);

INSERT INTO Presiding_Officer (presidingOfficerID, Name, ContactNumber, ExperienceYears, Address, PollingStationID) 
VALUES (26, 'Ayesha Siddiqui', '03006789012', 1, '26-Z Garden Town Plaza, Peshawar Cantt', 202);

INSERT INTO Presiding_Officer (presidingOfficerID, Name, ContactNumber, ExperienceYears, Address, PollingStationID) 
VALUES (27, 'Bilal Khan', '03007890123', 3, '27-AA Central Plaza, Peshawar Central', 251);

INSERT INTO Presiding_Officer (presidingOfficerID, Name, ContactNumber, ExperienceYears, Address, PollingStationID) 
VALUES (28, 'Sadia Aslam', '03008901234', 2, '28-BB Mall Road Plaza, University Road', 252);

INSERT INTO Presiding_Officer (presidingOfficerID, Name, ContactNumber, ExperienceYears, Address, PollingStationID) 
VALUES (29, 'Rizwan Ahmed', '03009012345', 4, '29-CC West End Avenue, Peshawar West', 301);

INSERT INTO Presiding_Officer (presidingOfficerID, Name, ContactNumber, ExperienceYears, Address, PollingStationID) 
VALUES (30, 'Fariha Khan', '03000123456', 3, '30-DD Downtown Mall, Hayatabad', 302);

INSERT INTO Presiding_Officer (presidingOfficerID, Name, ContactNumber, ExperienceYears, Address, PollingStationID) 
VALUES (31, 'Asad Mahmood', '03001234567', 5, '31-EE East Street, University Town', 351);

INSERT INTO Presiding_Officer (presidingOfficerID, Name, ContactNumber, ExperienceYears, Address, PollingStationID) 
VALUES (32, 'Saima Batool', '03002345678', 3, '32-FF City Towers, Cantt Area', 352);

INSERT INTO Presiding_Officer (presidingOfficerID, Name, ContactNumber, ExperienceYears, Address, PollingStationID) 
VALUES (33, 'Kamran Ali', '03003456789', 4, '33-GG Federal Plaza, Blue Area, Islamabad', 401);

INSERT INTO Presiding_Officer (presidingOfficerID, Name, ContactNumber, ExperienceYears, Address, PollingStationID) 
VALUES (34, 'Ayesha Malik', '03004567890', 2, '34-HH Parliament Road, G-5, Islamabad', 402);

INSERT INTO Family (FamilyID, family_member_name) VALUES (1, 'Ahmed Khan');

INSERT INTO Family (FamilyID, family_member_name) VALUES (2, 'Saeed Malik');

INSERT INTO Family (FamilyID, family_member_name) VALUES (3, 'Imran Shah');

INSERT INTO Family (FamilyID, family_member_name) VALUES (4, 'Ali Raza');

INSERT INTO Family (FamilyID, family_member_name) VALUES (5, 'Faisal Mahmood');

INSERT INTO Family (FamilyID, family_member_name) VALUES (6, 'Hamza Khan');

INSERT INTO Family (FamilyID, family_member_name) VALUES (7, 'Usman Ahmed');

INSERT INTO Family (FamilyID, family_member_name) VALUES (8, 'Bilal Abbas');

INSERT INTO Family (FamilyID, family_member_name) VALUES (9, 'Kamran Ali');

INSERT INTO Family (FamilyID, family_member_name) VALUES (10, 'Rizwan Ahmed');

INSERT INTO Family (FamilyID, family_member_name) VALUES (11, 'Asad Mahmood');

INSERT INTO Family (FamilyID, family_member_name) VALUES (12, 'Arslan Khan');

INSERT INTO Family (FamilyID, family_member_name) VALUES (13, 'Zubair Shah');

INSERT INTO Family (FamilyID, family_member_name) VALUES (14, 'Junaid Malik');

INSERT INTO Family (FamilyID, family_member_name) VALUES (15, 'Tahir Siddiqui');

SELECT * FROM Voter;

INSERT INTO Voter (VoterID, City, Gender, State, Email, Name, CNIC, DateOfBirth, family_ID) 
VALUES (3, 'Islamabad', 'M', 'Federal', 'imran.shah@gmail.com', 'Imran Shah', '61101-3456789-3', DATE '1997-11-25', 3);

INSERT INTO Voter (VoterID, City, Gender, State, Email, Name, CNIC, DateOfBirth, family_ID) 
VALUES (4, 'Peshawar', 'M', 'Khyber Pakhtunkhwa', 'ali.raza@yahoo.com', 'Ali Raza', '11401-4567890-4', DATE '1993-08-05', 4);

INSERT INTO Voter (VoterID, City, Gender, State, Email, Name, CNIC, DateOfBirth, family_ID) 
VALUES (5, 'Quetta', 'M', 'Balochistan', 'faisal.mahmood@gmail.com', 'Faisal Mahmood','51401-5678901-5', DATE '1998-07-12', 5);

INSERT INTO Voter (VoterID, City, Gender, State, Email, Name, CNIC, DateOfBirth, family_ID) 
VALUES (6, 'Karachi', 'M', 'Sindh', 'hamza.khan@gmail.com','Hamza Khan', '41605-6789012-6', DATE '1991-04-30', 6);

INSERT INTO Voter (VoterID, City, Gender, State, Email, Name, CNIC, DateOfBirth, family_ID) 
VALUES (7, 'Lahore', 'M', 'Punjab', 'usman.ahmed@yahoo.com','Usman Ahmed', '31203-7890123-7', DATE '1988-12-15', 7);

INSERT INTO Voter (VoterID, City, Gender, State, Email, Name, CNIC, DateOfBirth, family_ID) 
VALUES (8, 'Islamabad', 'M', 'Federal', 'bilal.abbas@gmail.com','Bilal Abbas', '61102-8901234-8', DATE '1996-02-18', 8);

INSERT INTO Voter (VoterID, City, Gender, State, Email, Name, CNIC, DateOfBirth, family_ID) 
VALUES (9, 'Peshawar', 'M', 'Khyber Pakhtunkhwa', 'kamran.ali@yahoo.com','Kamran Ali', '11402-9012345-9', DATE '1992-07-05', 9);

INSERT INTO Voter (VoterID, City, Gender, State, Email, Name, CNIC, DateOfBirth, family_ID) 
VALUES (10, 'Quetta', 'M', 'Balochistan', 'rizwan.ahmed@gmail.com', 'Rizwan Ahmed','51402-0123456-1', DATE '1994-10-20', 10);

INSERT INTO Voter (VoterID, City, Gender, State, Email, Name, CNIC, DateOfBirth, family_ID) 
VALUES (11, 'Karachi', 'F', 'Sindh', 'sara.khan@gmail.com','Sara Khan', '41604-1234567-2', DATE '1992-08-20', 1);

INSERT INTO Voter (VoterID, City, Gender, State, Email, Name, CNIC, DateOfBirth, family_ID) 
VALUES (12, 'Lahore', 'F', 'Punjab', 'fatima.ahmed@yahoo.com','Fatima Ahmed', '31202-2345678-3', DATE '1993-11-12', 2);

INSERT INTO Voter (VoterID, City, Gender, State, Email, Name, CNIC, DateOfBirth, family_ID) 
VALUES (13, 'Islamabad', 'F', 'Federal', 'mariam.ali@gmail.com','Mariam Ali', '61101-3456789-4', DATE '1997-06-25', 3);

INSERT INTO Voter (VoterID, City, Gender, State, Email, Name, CNIC, DateOfBirth, family_ID) 
VALUES (14, 'Peshawar', 'F', 'Khyber Pakhtunkhwa', 'sadia.khan@yahoo.com','Sadia Khan', '11401-4567890-5', DATE '1995-03-18', 4);

INSERT INTO Voter (VoterID, City, Gender, State, Email, Name, CNIC, DateOfBirth, family_ID) 
VALUES (15, 'Quetta', 'F', 'Balochistan', 'hina.amir@gmail.com','Hina Amir', '51401-5678901-6', DATE '1998-04-30', 5);

INSERT INTO Voter (VoterID, City, Gender, State, Email, Name, CNIC, DateOfBirth, family_ID) 
VALUES (16, 'Karachi', 'F', 'Sindh', 'ayesha.imran@gmail.com','Ayesha Imran', '41605-6789012-7', DATE '1990-05-01', 6);

INSERT INTO Voter (VoterID, City, Gender, State, Email, Name, CNIC, DateOfBirth, family_ID) 
VALUES (17, 'Lahore', 'F', 'Punjab', 'zara.asad@yahoo.com','Zara Asad', '31203-7890123-8', DATE '1991-12-10', 7);

INSERT INTO Voter (VoterID, City, Gender, State, Email, Name, CNIC, DateOfBirth, family_ID) 
VALUES (18, 'Islamabad', 'F', 'Federal', 'sumera.ahmad@gmail.com','Sumera Ahmad', '61102-8901234-9', DATE '1996-09-05', 8);

INSERT INTO Voter (VoterID, City, Gender, State, Email, Name, CNIC, DateOfBirth, family_ID) 
VALUES (19, 'Peshawar', 'F', 'Khyber Pakhtunkhwa', 'nazia.kamal@yahoo.com','Nazia Kamal', '11402-9012345-1', DATE '1994-10-25', 9);

INSERT INTO Voter (VoterID, City, Gender, State, Email, Name, CNIC, DateOfBirth, family_ID) 
VALUES (20, 'Quetta', 'F', 'Balochistan', 'saima.khan@gmail.com','Saima Khan', '51402-0123456-2', DATE '1992-11-15', 10);

INSERT INTO Voter (VoterID, City, Gender, State, Email, Name, CNIC, DateOfBirth, family_ID) 
VALUES (21, 'Karachi', 'M', 'Sindh', 'asad.mahmood@gmail.com','Asad Mahmood', '41604-1234567-3', DATE '1998-03-05', 11);

INSERT INTO Voter (VoterID, City, Gender, State, Email, Name, CNIC, DateOfBirth, family_ID) 
VALUES (22, 'Lahore', 'M', 'Punjab', 'arslan.khan@yahoo.com','Arslan Khan', '31202-2345678-4', DATE '2012-07-20', 12);

INSERT INTO Voter (VoterID, City, Gender, State, Email, Name, CNIC, DateOfBirth, family_ID) 
VALUES (23, 'Islamabad', 'M', 'Federal', 'zubair.shah@gmail.com', 'Zubair Shah','61101-3456789-5', DATE '2003-01-10', 13);

INSERT INTO Voter (VoterID, City, Gender, State, Email, Name, CNIC, DateOfBirth, family_ID) 
VALUES (24, 'Peshawar', 'M', 'Khyber Pakhtunkhwa', 'junaid.malik@yahoo.com', 'Junaid Malik','11401-4567890-6', DATE '2015-04-15', 14);

INSERT INTO Voter (VoterID, City, Gender, State, Email, Name, CNIC, DateOfBirth, family_ID) 
VALUES (25, 'Quetta', 'M', 'Balochistan', 'tahir.siddiqui@gmail.com', 'Tahir Siddiqui', '51401-5678901-7', DATE '2004-12-30', 15);

SELECT * FROM Voter;

INSERT INTO Family_Member_Record (MemberID, Gender, CNIC, DateOfBirth, family_ID, Voter_ID) 
VALUES (1, 'M', '41604-1234567-2', DATE '1992-08-20', 1, 11);

INSERT INTO Family_Member_Record (MemberID, Gender, CNIC, DateOfBirth, family_ID, Voter_ID) 
VALUES (2, 'F', '31202-2345678-3', DATE '1993-11-12', 2, 12);

INSERT INTO Family_Member_Record (MemberID, Gender, CNIC, DateOfBirth, family_ID, Voter_ID) 
VALUES (3, 'F', '61101-3456789-4', DATE '1997-06-25', 3, 13);

INSERT INTO Family_Member_Record (MemberID, Gender, CNIC, DateOfBirth, family_ID, Voter_ID) 
VALUES (4, 'F', '11401-4567890-5', DATE '1995-03-18', 4, 14);

INSERT INTO Family_Member_Record (MemberID, Gender, CNIC, DateOfBirth, family_ID, Voter_ID) 
VALUES (5, 'F', '51401-5678901-6', DATE '1998-04-30', 5, 15);

INSERT INTO Family_Member_Record (MemberID, Gender, CNIC, DateOfBirth, family_ID, Voter_ID) 
VALUES (6, 'F', '41605-6789012-7', DATE '1990-05-01', 6, 16);

INSERT INTO Family_Member_Record (MemberID, Gender, CNIC, DateOfBirth, family_ID, Voter_ID) 
VALUES (7, 'F', '31203-7890123-8', DATE '1991-12-10', 7, 17);

INSERT INTO Family_Member_Record (MemberID, Gender, CNIC, DateOfBirth, family_ID, Voter_ID) 
VALUES (8, 'F', '61102-8901234-9', DATE '1996-09-05', 8, 18);

INSERT INTO Family_Member_Record (MemberID, Gender, CNIC, DateOfBirth, family_ID, Voter_ID) 
VALUES (9, 'F', '11402-9012345-1', DATE '1994-10-25', 9, 19);

INSERT INTO Family_Member_Record (MemberID, Gender, CNIC, DateOfBirth, family_ID, Voter_ID) 
VALUES (10, 'F', '51402-0123456-2', DATE '1992-11-15', 10, 20);

INSERT INTO Family_Member_Record (MemberID, Gender, CNIC, DateOfBirth, family_ID, Voter_ID) 
VALUES (11, 'M', '41604-1234567-3', DATE '1998-03-05', 11, 21);

INSERT INTO Family_Member_Record (MemberID, Gender, CNIC, DateOfBirth, family_ID, Voter_ID) 
VALUES (12, 'M', '31202-2345678-4', DATE '2012-07-20', 12, 22);

INSERT INTO Family_Member_Record (MemberID, Gender, CNIC, DateOfBirth, family_ID, Voter_ID) 
VALUES (13, 'M', '61101-3456789-5', DATE '2003-01-10', 13, 23);

INSERT INTO Family_Member_Record (MemberID, Gender, CNIC, DateOfBirth, family_ID, Voter_ID) 
VALUES (14, 'M', '11401-4567890-6', DATE '2015-04-15', 14, 24);

INSERT INTO Family_Member_Record (MemberID, Gender, CNIC, DateOfBirth, family_ID, Voter_ID) 
VALUES (15, 'M', '51401-5678901-7', DATE '2004-12-30', 15, 25);

SELECT * FROM Family_Member_Record;

SELECT * FROM Elections;

INSERT INTO Vote (VoteID, VoterID, ConstituencyID, PollingStationID, ElectionID, CandidateID, Verified, VoteType, VoteDateTime) 
VALUES (1, 1, 1, 1, 24, 101, 'Yes', 'General', TIMESTAMP '2024-07-20 08:00:00');

INSERT INTO Vote (VoteID, VoterID, ConstituencyID, PollingStationID, ElectionID, CandidateID, Verified, VoteType, VoteDateTime) 
VALUES (3, 3, 17, 401, 24, 109, 'Yes', 'General', TIMESTAMP '2024-07-20 08:30:00');

INSERT INTO Vote (VoteID, VoterID, ConstituencyID, PollingStationID, ElectionID, CandidateID, Verified, VoteType, VoteDateTime) 
VALUES (4, 4, 12, 151, 24, 114, 'No', 'General', TIMESTAMP '2024-07-20 08:45:00');

INSERT INTO Vote (VoteID, VoterID, ConstituencyID, PollingStationID, ElectionID, CandidateID, Verified, VoteType, VoteDateTime) 
VALUES (5, 5, 11, 101, 24, 103, 'Yes', 'General', TIMESTAMP '2024-07-20 09:00:00');

INSERT INTO Vote (VoteID, VoterID, ConstituencyID, PollingStationID, ElectionID, CandidateID, Verified, VoteType, VoteDateTime) 
VALUES (6, 6, 2, 10, 24, 106, 'Yes', 'General', TIMESTAMP '2024-07-20 09:15:00');

INSERT INTO Vote (VoteID, VoterID, ConstituencyID, PollingStationID, ElectionID, CandidateID, Verified, VoteType, VoteDateTime) 
VALUES (7, 7, 7, 56, 24, 112, 'Yes', 'General', TIMESTAMP '2024-07-20 09:30:00');

INSERT INTO Vote (VoteID, VoterID, ConstituencyID, PollingStationID, ElectionID, CandidateID, Verified, VoteType, VoteDateTime) 
VALUES (8, 8, 17, 401, 24, 108, 'No', 'General', TIMESTAMP '2024-07-20 09:45:00');

INSERT INTO Vote (VoteID, VoterID, ConstituencyID, PollingStationID, ElectionID, CandidateID, Verified, VoteType, VoteDateTime) 
VALUES (9, 9, 13, 152, 24, 115, 'Yes', 'General', TIMESTAMP '2024-07-20 10:00:00');

INSERT INTO Vote (VoteID, VoterID, ConstituencyID, PollingStationID, ElectionID, CandidateID, Verified, VoteType, VoteDateTime) 
VALUES (10, 10, 11, 102, 24, 104, 'Yes', 'General', TIMESTAMP '2024-07-20 10:15:00');

INSERT INTO Vote (VoteID, VoterID, ConstituencyID, PollingStationID, ElectionID, CandidateID, Verified, VoteType, VoteDateTime) 
VALUES (11, 11, 3, 5, 24, 101, 'Yes', 'General', TIMESTAMP '2024-07-20 10:30:00');

INSERT INTO Vote (VoteID, VoterID, ConstituencyID, PollingStationID, ElectionID, CandidateID, Verified, VoteType, VoteDateTime) 
VALUES (12, 12, 8, 55, 24, 105, 'No', 'General', TIMESTAMP '2024-07-20 10:45:00');

INSERT INTO Vote (VoteID, VoterID, ConstituencyID, PollingStationID, ElectionID, CandidateID, Verified, VoteType, VoteDateTime) 
VALUES (13, 13, 17, 402, 24, 109, 'Yes', 'General', TIMESTAMP '2024-07-20 11:00:00');

INSERT INTO Vote (VoteID, VoterID, ConstituencyID, PollingStationID, ElectionID, CandidateID, Verified, VoteType, VoteDateTime) 
VALUES (14, 14, 14, 201, 24, 114, 'Yes', 'General', TIMESTAMP '2024-07-20 11:15:00');

INSERT INTO Vote (VoteID, VoterID, ConstituencyID, PollingStationID, ElectionID, CandidateID, Verified, VoteType, VoteDateTime) 
VALUES (15, 15, 11, 101, 24, 103, 'Yes', 'General', TIMESTAMP '2024-07-20 11:30:00');

INSERT INTO Vote (VoteID, VoterID, ConstituencyID, PollingStationID, ElectionID, CandidateID, Verified, VoteType, VoteDateTime) 
VALUES (16, 16, 4, 8, 24, 106, 'Yes', 'General', TIMESTAMP '2024-07-20 11:45:00');

INSERT INTO Vote (VoteID, VoterID, ConstituencyID, PollingStationID, ElectionID, CandidateID, Verified, VoteType, VoteDateTime) 
VALUES (17, 17, 9, 59, 24, 112, 'Yes', 'General', TIMESTAMP '2024-07-20 12:00:00');

INSERT INTO Vote (VoteID, VoterID, ConstituencyID, PollingStationID, ElectionID, CandidateID, Verified, VoteType, VoteDateTime) 
VALUES (18, 18, 17, 401, 24, 108, 'No', 'General', TIMESTAMP '2024-07-20 12:15:00');

INSERT INTO Vote (VoteID, VoterID, ConstituencyID, PollingStationID, ElectionID, CandidateID, Verified, VoteType, VoteDateTime) 
VALUES (19, 19, 15, 351, 24, 115, 'Yes', 'General', TIMESTAMP '2024-07-20 12:30:00');

INSERT INTO Vote (VoteID, VoterID, ConstituencyID, PollingStationID, ElectionID, CandidateID, Verified, VoteType, VoteDateTime) 
VALUES (20, 20, 11, 102, 24, 104, 'Yes', 'General', TIMESTAMP '2024-07-20 12:45:00');

INSERT INTO Vote (VoteID, VoterID, ConstituencyID, PollingStationID, ElectionID, CandidateID, Verified, VoteType, VoteDateTime) 
VALUES (21, 21, 5, 9, 24, 101, 'Yes', 'General', TIMESTAMP '2024-07-20 13:00:00');

INSERT INTO Vote (VoteID, VoterID, ConstituencyID, PollingStationID, ElectionID, CandidateID, Verified, VoteType, VoteDateTime) 
VALUES (23, 23, 17, 402, 24, 109, 'Yes', 'General', TIMESTAMP '2024-07-20 13:30:00');

INSERT INTO Vote (VoteID, VoterID, ConstituencyID, PollingStationID, ElectionID, CandidateID, Verified, VoteType, VoteDateTime) 
VALUES (25, 25, 11, 101, 24, 103, 'Yes', 'General', TIMESTAMP '2024-07-20 14:00:00');

SELECT * FROM Candidate;

SELECT * FROM Political_Party;

SELECT * FROM Candidate;

INSERT INTO Candidate (candidate_ID, Name, date_of_birth, gender, religion, party_ID)  
VALUES (115, 'Sadia Ahmed', TO_DATE('1983-03-12', 'YYYY-MM-DD'), 'F', 'Islam', 15);

INSERT INTO Candidate (candidate_ID, Name, date_of_birth, gender, religion, party_ID)  
VALUES (116, 'Asif Ali', TO_DATE('1980-05-18', 'YYYY-MM-DD'), 'M', 'Islam', 1);

INSERT INTO Candidate (candidate_ID, Name, date_of_birth, gender, religion, party_ID)  
VALUES (117, 'Zainab Riaz', TO_DATE('1982-06-22', 'YYYY-MM-DD'), 'F', 'Islam', 2);

INSERT INTO Candidate (candidate_ID, Name, date_of_birth, gender, religion, party_ID)  
VALUES (118, 'Kashif Raza', TO_DATE('1978-04-23', 'YYYY-MM-DD'), 'M', 'Islam', 1);

INSERT INTO Candidate (candidate_ID, Name, date_of_birth, gender, religion, party_ID)  
VALUES (119, 'Farah Khan', TO_DATE('1982-05-15', 'YYYY-MM-DD'), 'F', 'Islam', 2);

INSERT INTO Candidate (candidate_ID, Name, date_of_birth, gender, religion, party_ID)  
VALUES (120, 'Umer Aslam', TO_DATE('1979-07-19', 'YYYY-MM-DD'), 'M', 'Islam', 3);

INSERT INTO Candidate (candidate_ID, Name, date_of_birth, gender, religion, party_ID)  
VALUES (121, 'Nadia Malik', TO_DATE('1984-09-05', 'YYYY-MM-DD'), 'F', 'Other', 4);

INSERT INTO Candidate (candidate_ID, Name, date_of_birth, gender, religion, party_ID)  
VALUES (122, 'Salman Shah', TO_DATE('1977-11-22', 'YYYY-MM-DD'), 'M', 'Islam', 5);

INSERT INTO Candidate (candidate_ID, Name, date_of_birth, gender, religion, party_ID)  
VALUES (123, 'Ayesha Qureshi', TO_DATE('1981-01-10', 'YYYY-MM-DD'), 'F', 'Islam', 6);

INSERT INTO Candidate (candidate_ID, Name, date_of_birth, gender, religion, party_ID)  
VALUES (124, 'Imran Rafiq', TO_DATE('1976-02-28', 'YYYY-MM-DD'), 'M', 'Islam', 7);

INSERT INTO Candidate (candidate_ID, Name, date_of_birth, gender, religion, party_ID)  
VALUES (125, 'Mehwish Ahmed', TO_DATE('1985-03-16', 'YYYY-MM-DD'), 'F', 'Other', 8);

INSERT INTO Candidate (candidate_ID, Name, date_of_birth, gender, religion, party_ID)  
VALUES (126, 'Usman Tariq', TO_DATE('1980-04-07', 'YYYY-MM-DD'), 'M', 'Islam', 9);

INSERT INTO Candidate (candidate_ID, Name, date_of_birth, gender, religion, party_ID)  
VALUES (127, 'Sara Kamal', TO_DATE('1975-06-12', 'YYYY-MM-DD'), 'F', 'Islam', 10);

INSERT INTO Candidate (candidate_ID, Name, date_of_birth, gender, religion, party_ID)  
VALUES (128, 'Bilal Ansari', TO_DATE('1978-08-25', 'YYYY-MM-DD'), 'M', 'Islam', 11);

INSERT INTO Candidate (candidate_ID, Name, date_of_birth, gender, religion, party_ID)  
VALUES (129, 'Sania Farooq', TO_DATE('1983-10-19', 'YYYY-MM-DD'), 'F', 'Islam', 12);

INSERT INTO Candidate (candidate_ID, Name, date_of_birth, gender, religion, party_ID)  
VALUES (130, 'Murtaza Ali', TO_DATE('1977-12-03', 'YYYY-MM-DD'), 'M', 'Islam', 13);

INSERT INTO Candidate (candidate_ID, Name, date_of_birth, gender, religion, party_ID)  
VALUES (131, 'Mona Shahid', TO_DATE('1981-01-25', 'YYYY-MM-DD'), 'F', 'Other', 14);

INSERT INTO Candidate (candidate_ID, Name, date_of_birth, gender, religion, party_ID)  
VALUES (132, 'Zafar Iqbal', TO_DATE('1976-03-14', 'YYYY-MM-DD'), 'M', 'Islam', 15);

INSERT INTO Candidate (candidate_ID, Name, date_of_birth, gender, religion, party_ID)  
VALUES (133, 'Rubina Akhtar', TO_DATE('1985-05-30', 'YYYY-MM-DD'), 'F', 'Islam', 1);

INSERT INTO Candidate (candidate_ID, Name, date_of_birth, gender, religion, party_ID)  
VALUES (134, 'Noman Javed', TO_DATE('1978-07-17', 'YYYY-MM-DD'), 'M', 'Islam', 2);

INSERT INTO Candidate (candidate_ID, Name, date_of_birth, gender, religion, party_ID)  
VALUES (135, 'Asma Riaz', TO_DATE('1984-09-21', 'YYYY-MM-DD'), 'F', 'Islam', 3);

INSERT INTO Candidate (candidate_ID, Name, date_of_birth, gender, religion, party_ID)  
VALUES (136, 'Rizwan Ahmed', TO_DATE('1979-11-08', 'YYYY-MM-DD'), 'M', 'Islam', 4);

SELECT * FROM Candidate;

SELECT * FROM Constituency;

INSERT INTO Constituency (ConstituencyID, ConstituencyName, ProvinceName) 
VALUES (18, 'Karachi South', 'Sindh');

INSERT INTO Constituency (ConstituencyID, ConstituencyName, ProvinceName) 
VALUES (19, 'Karachi North', 'Sindh');

INSERT INTO Constituency (ConstituencyID, ConstituencyName, ProvinceName) 
VALUES (20, 'Karachi Central', 'Sindh');

INSERT INTO Constituency (ConstituencyID, ConstituencyName, ProvinceName) 
VALUES (21, 'Karachi West', 'Sindh');

INSERT INTO Constituency (ConstituencyID, ConstituencyName, ProvinceName) 
VALUES (22, 'Karachi East', 'Sindh');

INSERT INTO Constituency (ConstituencyID, ConstituencyName, ProvinceName) 
VALUES (23, 'Lahore South', 'Punjab');

INSERT INTO Constituency (ConstituencyID, ConstituencyName, ProvinceName) 
VALUES (24, 'Lahore North', 'Punjab');

INSERT INTO Constituency (ConstituencyID, ConstituencyName, ProvinceName) 
VALUES (25, 'Lahore Central', 'Punjab');

INSERT INTO Constituency (ConstituencyID, ConstituencyName, ProvinceName) 
VALUES (26, 'Lahore West', 'Punjab');

INSERT INTO Constituency (ConstituencyID, ConstituencyName, ProvinceName) 
VALUES (27, 'Lahore East', 'Punjab');

INSERT INTO Constituency (ConstituencyID, ConstituencyName, ProvinceName) 
VALUES (28, 'Quetta East', 'Balochistan');

INSERT INTO Constituency (ConstituencyID, ConstituencyName, ProvinceName) 
VALUES (29, 'Peshawar South', 'Khyber Pakhtunkhwa');

INSERT INTO Constituency (ConstituencyID, ConstituencyName, ProvinceName) 
VALUES (30, 'Peshawar North', 'Khyber Pakhtunkhwa');

INSERT INTO Constituency (ConstituencyID, ConstituencyName, ProvinceName) 
VALUES (31, 'Peshawar Central', 'Khyber Pakhtunkhwa');

INSERT INTO Constituency (ConstituencyID, ConstituencyName, ProvinceName) 
VALUES (32, 'Peshawar East', 'Khyber Pakhtunkhwa');

INSERT INTO Constituency (ConstituencyID, ConstituencyName, ProvinceName) 
VALUES (33, 'Peshawar West', 'Khyber Pakhtunkhwa');

INSERT INTO Constituency (ConstituencyID, ConstituencyName, ProvinceName) 
VALUES (34, 'Islamabad Federal', 'Federal');

SELECT * FROM Constituency;

SELECT * FROM Candidate;

SELECT * FROM Polling_Station;

CREATE TABLE Candidate_Position ( 
    candidate_id INT, 
    polling_station_id INT, 
    position VARCHAR2(50), 
    party_id INT, 
    PRIMARY KEY (candidate_id, polling_station_id, position), 
    FOREIGN KEY (candidate_id) REFERENCES Candidate(candidate_id), 
    FOREIGN KEY (polling_station_id) REFERENCES Polling_Station(pollingstationid), 
    FOREIGN KEY (party_id) REFERENCES Political_Party(party_id) 
);

SELECT * FROM CANDIDATE;

SELECT * FROM Polling_Station;

CREATE TABLE Candidate_Position ( 
    candidate_position_id INT PRIMARY KEY, 
    candidate_id INT, 
    pollingstationid INT, 
    position VARCHAR2(3), -- This can be 'MPA' or 'MNA' 
    party_id INT, 
    FOREIGN KEY (candidate_id) REFERENCES Candidate(candidate_id), 
    FOREIGN KEY (pollingstationid) REFERENCES Polling_Station(pollingstationid), 
    FOREIGN KEY (party_id) REFERENCES Political_Party(party_id) 
);

SELECT * FROM Candidate;

INSERT ALL  
    INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES (5, 105, 2, 'MPA', 5) 
    INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES (6, 106, 2, 'MPA', 6) 
    INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES (7, 107, 2, 'MNA', 7) 
    INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES (8, 108, 2, 'MNA', 8) 
SELECT * FROM dual;

SELECT * FROM Political_Party;

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) 
VALUES (2, 104, 1, 'MPA', 4);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id)  
VALUES (45, 109, 52, 'MPA', 9);

SELECT * FROM Polling_STation;

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) 
VALUES (3, 103, 1, 'MNA', 3);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) 
VALUES (4, 104, 1, 'MNA', 4);

INSERT ALL  
    INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES (9, 109, 3, 'MPA', 9) 
    INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES (10, 111, 3, 'MPA', 11) 
    INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES (11, 111, 3, 'MNA', 11) 
    INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES (12, 112, 3, 'MNA', 12) 
SELECT * FROM dual;

INSERT ALL  
    INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES (13, 113, 4, 'MPA', 13) 
    INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES (14, 114, 4, 'MPA', 14) 
    INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES (15, 115, 4, 'MNA', 15) 
    INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES (16, 116, 4, 'MNA', 1) 
SELECT * FROM dual;

INSERT ALL  
    INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES (17, 117, 5, 'MPA', 2) 
    INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES (18, 118, 5, 'MPA', 1) 
    INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES (19, 119, 5, 'MNA', 2) 
    INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES (20, 120, 5, 'MNA', 3) 
SELECT * FROM dual;

INSERT ALL  
    INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES (21, 121, 6, 'MPA', 4) 
    INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES (22, 122, 6, 'MPA', 5) 
    INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES (23, 123, 6, 'MNA', 6) 
    INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES (24, 124, 6, 'MNA', 7) 
SELECT * FROM dual;

INSERT ALL  
    INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES (25, 125, 7, 'MPA', 8) 
    INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES (26, 126, 7, 'MPA', 9) 
    INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES (27, 127, 7, 'MNA', 10) 
    INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES (28, 128, 7, 'MNA', 11) 
SELECT * FROM dual;

INSERT ALL  
    INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES (29, 129, 8, 'MPA', 12) 
    INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES (30, 130, 8, 'MPA', 13) 
    INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES (31, 131, 8, 'MNA', 14) 
    INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES (32, 132, 8, 'MNA', 15) 
SELECT * FROM dual;

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(46, 110, 52, 'MPA', 10);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(47, 111, 52, 'MNA', 11);

INSERT ALL  
    INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES (33, 133, 9, 'MPA', 1) 
    INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES (34, 134, 9, 'MPA', 2) 
    INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES (35, 135, 9, 'MNA', 3) 
    INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES (36, 136, 9, 'MNA', 4) 
SELECT * FROM dual;

INSERT ALL  
    INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES (37, 101, 10, 'MPA', 1) 
    INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES (38, 102, 10, 'MPA', 2) 
    INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES (39, 103, 10, 'MNA', 3) 
    INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES (40, 104, 10, 'MNA', 4) 
SELECT * FROM dual;

INSERT ALL  
    INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES (41, 105, 51, 'MPA', 5) 
    INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES (42, 106, 51, 'MPA', 6) 
    INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES (43, 107, 51, 'MNA', 7) 
    INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES (44, 108, 51, 'MNA', 8) 
SELECT * FROM dual;

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(81, 101, 101, 'MPA', 1);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(82, 102, 102, 'MPA', 2);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(83, 103, 151, 'MPA', 3);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(84, 104, 152, 'MPA', 4);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(85, 105, 201, 'MPA', 5);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(86, 106, 202, 'MPA', 6);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(48, 112, 52, 'MNA', 12);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(49, 113, 53, 'MPA', 13);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(50, 114, 53, 'MPA', 14);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(51, 115, 53, 'MNA', 15);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(52, 116, 53, 'MNA', 1);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(53, 117, 54, 'MPA', 2);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(54, 118, 54, 'MPA', 1);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(55, 119, 54, 'MNA', 2);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(56, 120, 54, 'MNA', 3);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(57, 121, 55, 'MPA', 4);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(58, 122, 55, 'MPA', 5);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(59, 123, 55, 'MNA', 6);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(60, 124, 55, 'MNA', 7);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(61, 125, 56, 'MPA', 8);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(62, 126, 56, 'MPA', 9);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(63, 127, 56, 'MNA', 10);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(64, 128, 56, 'MNA', 11);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(65, 129, 57, 'MPA', 12);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(66, 130, 57, 'MPA', 13);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(67, 131, 57, 'MNA', 14);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(68, 132, 57, 'MNA', 15);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(69, 133, 58, 'MPA', 1);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(70, 134, 58, 'MPA', 2);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(71, 135, 58, 'MNA', 3);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(72, 136, 58, 'MNA', 4);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(73, 101, 59, 'MPA', 1);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(74, 102, 59, 'MPA', 2);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(75, 103, 59, 'MNA', 3);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(76, 104, 59, 'MNA', 4);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(77, 105, 60, 'MPA', 5);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(78, 106, 60, 'MPA', 6);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(79, 107, 60, 'MNA', 7);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(80, 108, 60, 'MNA', 8);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(87, 107, 251, 'MPA', 7);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(88, 108, 252, 'MPA', 8);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(89, 109, 301, 'MPA', 9);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(90, 110, 302, 'MPA', 10);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(91, 111, 351, 'MPA', 11);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(92, 112, 352, 'MPA', 12);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(93, 113, 401, 'MPA', 13);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(94, 114, 402, 'MPA', 14);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(95, 115, 101, 'MPA', 15);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(96, 116, 102, 'MPA', 1);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(97, 117, 101, 'MNA', 2);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(98, 118, 151, 'MPA', 1);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(99, 119, 152, 'MPA', 2);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(100, 120, 201, 'MPA', 3);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(101, 121, 202, 'MPA', 4);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(102, 122, 251, 'MPA', 5);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(103, 123, 252, 'MPA', 6);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(104, 124, 301, 'MPA', 7);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(105, 125, 302, 'MPA', 8);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(106, 126, 351, 'MPA', 9);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(107, 127, 352, 'MPA', 10);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(108, 128, 401, 'MPA', 11);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(109, 129, 402, 'MPA', 12);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(110, 130, 401, 'MNA', 13);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(111, 131, 402, 'MNA', 14);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(112, 132, 101, 'MNA', 15);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(113, 133, 102, 'MNA', 1);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(114, 134, 151, 'MNA', 2);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(115, 135, 152, 'MNA', 3);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(116, 136, 201, 'MNA', 4);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(117, 101, 202, 'MNA', 1);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(118, 102, 251, 'MNA', 2);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(119, 103, 252, 'MNA', 3);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(120, 104, 301, 'MNA', 4);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(121, 105, 302, 'MNA', 5);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(122, 106, 351, 'MNA', 6);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(123, 107, 352, 'MNA', 7);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(124, 108, 152, 'MNA', 8);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(125, 106, 201, 'MNA', 9);

SELECT * FROM Candidate_Position;

SELECT * FROM Voter;

SELECT * FROM Voter;

SELECT * FROM Family;

SELECT * FROM Family_Member_Record;

SELECT * FROM Family;

SELECT * FROM Voter;

SELECT * FROM Voter;

INSERT ALL 
    INTO Voter (VOTERID, CITY, GENDER, STATE, EMAIL, NAME, CNIC, DATEOFBIRTH, FAMILY_ID) VALUES (26, 'Islamabad', 'F', 'Federal', 'sana.khan@gmail.com', 'Sana Khan', '61102-8901235-8', TO_DATE('1996-10-30', 'YYYY-MM-DD'), 11) 
    INTO Voter (VOTERID, CITY, GENDER, STATE, EMAIL, NAME, CNIC, DATEOFBIRTH, FAMILY_ID) VALUES (27, 'Peshawar', 'F', 'Khyber Pakhtunkhwa', 'khadija.yousaf@yahoo.com', 'Khadija Yousaf', '11402-9015345-9', TO_DATE('1994-03-25', 'YYYY-MM-DD'), 12) 
    INTO Voter (VOTERID, CITY, GENDER, STATE, EMAIL, NAME, CNIC, DATEOFBIRTH, FAMILY_ID) VALUES (28, 'Quetta', 'F', 'Balochistan', 'farah.khalid@gmail.com', 'Farah Khalid', '51402-0125456-1', TO_DATE('1992-08-10', 'YYYY-MM-DD'), 13) 
    INTO Voter (VOTERID, CITY, GENDER, STATE, EMAIL, NAME, CNIC, DATEOFBIRTH, FAMILY_ID) VALUES (29, 'Karachi', 'F', 'Sindh', 'zainab.rasheed@gmail.com', 'Zainab Rasheed', '41604-1234467-2', TO_DATE('1991-12-05', 'YYYY-MM-DD'), 14) 
    INTO Voter (VOTERID, CITY, GENDER, STATE, EMAIL, NAME, CNIC, DATEOFBIRTH, FAMILY_ID) VALUES (30, 'Lahore', 'F', 'Punjab', 'maryam.javed@yahoo.com', 'Maryam Javed', '31202-2345668-3', TO_DATE('1990-09-20', 'YYYY-MM-DD'), 15) 
    INTO Voter (VOTERID, CITY, GENDER, STATE, EMAIL, NAME, CNIC, DATEOFBIRTH, FAMILY_ID) VALUES (31, 'Islamabad', 'F', 'Federal', 'sadia.aslam@gmail.com', 'Sadia Aslam', '61101-3454789-4', TO_DATE('1998-04-15', 'YYYY-MM-DD'), 1) 
    INTO Voter (VOTERID, CITY, GENDER, STATE, EMAIL, NAME, CNIC, DATEOFBIRTH, FAMILY_ID) VALUES (32, 'Peshawar', 'F', 'Khyber Pakhtunkhwa', 'saba.noor@yahoo.com', 'Saba Noor', '11401-4565890-5', TO_DATE('1996-07-02', 'YYYY-MM-DD'), 2) 
    INTO Voter (VOTERID, CITY, GENDER, STATE, EMAIL, NAME, CNIC, DATEOFBIRTH, FAMILY_ID) VALUES (33, 'Quetta', 'F', 'Balochistan', 'saima.khalid@gmail.com', 'Saima Khalid', '51401-5678401-6', TO_DATE('1994-12-25', 'YYYY-MM-DD'), 3) 
    INTO Voter (VOTERID, CITY, GENDER, STATE, EMAIL, NAME, CNIC, DATEOFBIRTH, FAMILY_ID) VALUES (34, 'Karachi', 'M', 'Sindh', 'asim.bashir@gmail.com', 'Asim Bashir', '41605-6789312-7', TO_DATE('1993-05-30', 'YYYY-MM-DD'), 4) 
    INTO Voter (VOTERID, CITY, GENDER, STATE, EMAIL, NAME, CNIC, DATEOFBIRTH, FAMILY_ID) VALUES (35, 'Lahore', 'M', 'Punjab', 'hassan.umar@yahoo.com', 'Hassan Umar', '31203-7890323-8', TO_DATE('1992-02-18', 'YYYY-MM-DD'), 5) 
    INTO Voter (VOTERID, CITY, GENDER, STATE, EMAIL, NAME, CNIC, DATEOFBIRTH, FAMILY_ID) VALUES (36, 'Islamabad', 'M', 'Federal', 'ali.zaman@gmail.com', 'Ali Zaman', '61102-8901634-9', TO_DATE('1991-10-05', 'YYYY-MM-DD'), 6) 
    INTO Voter (VOTERID, CITY, GENDER, STATE, EMAIL, NAME, CNIC, DATEOFBIRTH, FAMILY_ID) VALUES (37, 'Peshawar', 'M', 'Khyber Pakhtunkhwa', 'zubair.javed@yahoo.com', 'Zubair Javed', '11402-9812345-1', TO_DATE('1990-09-15', 'YYYY-MM-DD'), 7) 
    INTO Voter (VOTERID, CITY, GENDER, STATE, EMAIL, NAME, CNIC, DATEOFBIRTH, FAMILY_ID) VALUES (38, 'Quetta', 'M', 'Balochistan', 'umar.khalid@gmail.com', 'Umar Khalid', '51402-0123656-2', TO_DATE('1989-11-01', 'YYYY-MM-DD'), 8) 
    INTO Voter (VOTERID, CITY, GENDER, STATE, EMAIL, NAME, CNIC, DATEOFBIRTH, FAMILY_ID) VALUES (39, 'Karachi', 'F', 'Sindh', 'maham.naeem@gmail.com', 'Maham Naeem', '41604-1234577-3', TO_DATE('1988-03-20', 'YYYY-MM-DD'), 9) 
    INTO Voter (VOTERID, CITY, GENDER, STATE, EMAIL, NAME, CNIC, DATEOFBIRTH, FAMILY_ID) VALUES (40, 'Lahore', 'F', 'Punjab', 'nida.ahmed@yahoo.com', 'Nida Ahmed', '31202-2345648-4', TO_DATE('1987-06-15', 'YYYY-MM-DD'), 10) 
    INTO Voter (VOTERID, CITY, GENDER, STATE, EMAIL, NAME, CNIC, DATEOFBIRTH, FAMILY_ID) VALUES (41, 'Islamabad', 'F', 'Federal', 'zainab.ali@gmail.com', 'Zainab Ali', '61101-3456689-5', TO_DATE('1996-01-12', 'YYYY-MM-DD'), 11) 
    INTO Voter (VOTERID, CITY, GENDER, STATE, EMAIL, NAME, CNIC, DATEOFBIRTH, FAMILY_ID) VALUES (42, 'Peshawar', 'F', 'Khyber Pakhtunkhwa', 'sadia.rasheed@yahoo.com', 'Sadia Rasheed', '11401-4567790-6', TO_DATE('1995-04-05', 'YYYY-MM-DD'), 12) 
    INTO Voter (VOTERID, CITY, GENDER, STATE, EMAIL, NAME, CNIC, DATEOFBIRTH, FAMILY_ID) VALUES (43, 'Quetta', 'F', 'Balochistan', 'sara.farooq@gmail.com', 'Sara Farooq', '51401-5678401-7', TO_DATE('1994-07-30', 'YYYY-MM-DD'), 13) 
    INTO Voter (VOTERID, CITY, GENDER, STATE, EMAIL, NAME, CNIC, DATEOFBIRTH, FAMILY_ID) VALUES (44, 'Karachi', 'F', 'Sindh', 'zoya.naeem@gmail.com', 'Zoya Naeem', '41605-6789612-8', TO_DATE('1993-10-25', 'YYYY-MM-DD'), 14) 
    INTO Voter (VOTERID, CITY, GENDER, STATE, EMAIL, NAME, CNIC, DATEOFBIRTH, FAMILY_ID) VALUES (45, 'Lahore', 'F', 'Punjab', 'maryam.ali@yahoo.com', 'Maryam Ali', '31203-7890723-9', TO_DATE('1992-11-15', 'YYYY-MM-DD'), 15) 
SELECT * FROM dual;

SELECT * FROM Family_Member_Record;

SELECT * FROM Family_Member_Record;

SELECT * FROM Family;

SELECT * FROM Family_Member_Record ;

SELECT * FROM Family_Member_Record ;

INSERT INTO Family_Member_Record (MEMBERID, GENDER, CNIC, DATEOFBIRTH, FAMILY_ID, VOTER_ID) 
SELECT  
    15 + ROW_NUMBER() OVER (ORDER BY V.VOTERID) AS MEMBERID, 
    V.GENDER, 
    V.CNIC, 
    V.DATEOFBIRTH, 
    V.FAMILY_ID, 
    V.VOTERID AS VOTER_ID 
FROM Voter V 
WHERE V.FAMILY_ID IS NOT NULL 
AND V.VOTERID NOT IN (SELECT VOTER_ID FROM Family_Member_Record);

SELECT * FROM Vote ;

SELECT * FROM Candidate_Position;

select * from candidate_position;

select * from vote;

select * from family_member_record;

select * from vote;

select * from voter;

select * from vote;

select * from candidate_position;

SELECT *  
FROM candidate_position 
ORDER BY POLLINGSTATIONID ASC;

SELECT *  
FROM voter;

SELECT *  
FROM elections;

select * from constituency;

select * from candidate_position;

select * from candidate_position 
order by pollingstationid asc;

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(50, 114, 53, 'MPA', 14);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(51, 115, 53, 'MNA', 15);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(52, 116, 53, 'MNA', 1);

select * from candidate_position 
order by candidate_positon_id asc;

select * from candidate_position 
order by candidate_position_id asc 
;

SELECT * FROM candidate_position FETCH NEXT 100 ROWS ONLY;

SELECT * FROM candidate_position FETCH NEXT 100 ROWS ONLY order by candidate_position_id asc;

select * from candidate_position where pollingstationid=401 or 402;

select * from candidate_position where pollingstationid=401 or pollingstationid=402;

    select * from constituency;

 select * from polling_station;

CREATE TABLE Candidate_Position ( 
    candidate_position_id INT PRIMARY KEY, 
    candidate_id INT, 
    pollingstationid INT, 
    position VARCHAR2(3), -- This can be 'MPA' or 'MNA' 
    party_id INT, 
    FOREIGN KEY (candidate_id) REFERENCES Candidate(candidate_id), 
    FOREIGN KEY (pollingstationid) REFERENCES Polling_Station(pollingstationid), 
    FOREIGN KEY (party_id) REFERENCES Political_Party(party_id) 
);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) 
VALUES (1, 101, 1, 'MPA', 1);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) 
VALUES (2, 104, 1, 'MPA', 4);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) 
VALUES (3, 103, 1, 'MNA', 3);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) 
VALUES (4, 104, 1, 'MNA', 4);

INSERT ALL  
    INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES (5, 105, 2, 'MPA', 5) 
    INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES (6, 106, 2, 'MPA', 6) 
    INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES (7, 105, 2, 'MNA', 5) 
    INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES (8, 108, 2, 'MNA', 8) 
SELECT * FROM dual;

INSERT ALL  
    INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES (9, 109, 3, 'MPA', 9) 
    INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES (10, 111, 3, 'MPA', 11) 
    INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES (11, 111, 3, 'MNA', 11) 
    INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES (12, 112, 3, 'MNA', 12) 
SELECT * FROM dual;

INSERT ALL  
    INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES (13, 113, 4, 'MPA', 13) 
    INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES (14, 114, 4, 'MPA', 14) 
    INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES (15, 115, 4, 'MNA', 15) 
    INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES (16, 116, 4, 'MNA', 1) 
SELECT * FROM dual;

INSERT ALL  
    INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES (17, 117, 5, 'MPA', 2) 
    INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES (18, 118, 5, 'MPA', 1) 
    INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES (19, 119, 5, 'MNA', 2) 
    INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES (20, 120, 5, 'MNA', 3) 
SELECT * FROM dual;

INSERT ALL  
    INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES (21, 121, 6, 'MPA', 4) 
    INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES (22, 122, 6, 'MPA', 5) 
    INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES (23, 123, 6, 'MNA', 6) 
    INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES (24, 124, 6, 'MNA', 7) 
SELECT * FROM dual;

INSERT ALL  
    INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES (25, 125, 7, 'MPA', 8) 
    INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES (26, 126, 7, 'MPA', 9) 
    INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES (27, 127, 7, 'MNA', 10) 
    INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES (28, 128, 7, 'MNA', 11) 
SELECT * FROM dual;

INSERT ALL  
    INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES (29, 129, 8, 'MPA', 12) 
    INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES (30, 130, 8, 'MPA', 13) 
    INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES (31, 131, 8, 'MNA', 14) 
    INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES (32, 132, 8, 'MNA', 15) 
SELECT * FROM dual;

INSERT ALL  
    INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES (33, 133, 9, 'MPA', 1) 
    INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES (34, 134, 9, 'MPA', 2) 
    INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES (35, 135, 9, 'MNA', 3) 
    INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES (36, 136, 9, 'MNA', 4) 
SELECT * FROM dual;

INSERT ALL  
    INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES (37, 101, 10, 'MPA', 1) 
    INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES (38, 102, 10, 'MPA', 2) 
    INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES (39, 103, 10, 'MNA', 3) 
    INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES (40, 104, 10, 'MNA', 4) 
SELECT * FROM dual;

INSERT ALL  
    INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES (41, 105, 51, 'MPA', 5) 
    INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES (42, 106, 51, 'MPA', 6) 
    INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES (43, 107, 51, 'MNA', 7) 
    INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES (44, 108, 51, 'MNA', 8) 
SELECT * FROM dual;

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id)  
VALUES (45, 109, 52, 'MPA', 9);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(46, 110, 52, 'MPA', 10);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(47, 111, 52, 'MNA', 11);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(48, 112, 52, 'MNA', 12);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(49, 113, 53, 'MPA', 13);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(50, 114, 53, 'MPA', 14);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(51, 115, 53, 'MNA', 15);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(52, 116, 53, 'MNA', 1);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(53, 117, 54, 'MPA', 2);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(54, 118, 54, 'MPA', 1);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(55, 119, 54, 'MNA', 2);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(56, 120, 54, 'MNA', 3);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(57, 121, 55, 'MPA', 4);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(58, 122, 55, 'MPA', 5);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(59, 123, 55, 'MNA', 6);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(60, 124, 55, 'MNA', 7);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(61, 125, 56, 'MPA', 8);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(62, 126, 56, 'MPA', 9);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(63, 127, 56, 'MNA', 10);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(64, 128, 56, 'MNA', 11);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(65, 129, 57, 'MPA', 12);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(66, 130, 57, 'MPA', 13);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(67, 131, 57, 'MNA', 14);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(68, 132, 57, 'MNA', 15);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(69, 133, 58, 'MPA', 1);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(70, 134, 58, 'MPA', 2);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(71, 135, 58, 'MNA', 3);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(72, 136, 58, 'MNA', 4);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(73, 101, 59, 'MPA', 1);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(74, 102, 59, 'MPA', 2);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(75, 103, 59, 'MNA', 3);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(76, 104, 59, 'MNA', 4);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(77, 105, 60, 'MPA', 5);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(78, 106, 60, 'MPA', 6);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(79, 107, 60, 'MNA', 7);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(80, 108, 60, 'MNA', 8);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(81, 101, 101, 'MPA', 1);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(82, 102, 102, 'MPA', 2);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(83, 103, 151, 'MPA', 3);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(84, 104, 152, 'MPA', 4);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(85, 105, 201, 'MPA', 5);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(86, 106, 202, 'MPA', 6);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(87, 107, 251, 'MPA', 7);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(88, 108, 252, 'MPA', 8);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(89, 109, 301, 'MPA', 9);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(90, 110, 302, 'MPA', 10);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(91, 111, 351, 'MPA', 11);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(92, 112, 352, 'MPA', 12);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(93, 113, 401, 'MPA', 13);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(94, 114, 402, 'MPA', 14);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(95, 115, 101, 'MPA', 15);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(96, 116, 102, 'MPA', 1);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(97, 117, 101, 'MNA', 2);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(98, 118, 151, 'MPA', 1);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(99, 119, 152, 'MPA', 2);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(100, 120, 201, 'MPA', 3);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(101, 121, 202, 'MPA', 4);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(102, 122, 251, 'MPA', 5);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(103, 123, 252, 'MPA', 6);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(104, 124, 301, 'MPA', 7);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(105, 125, 302, 'MPA', 8);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(106, 126, 351, 'MPA', 9);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(107, 127, 352, 'MPA', 10);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(108, 128, 401, 'MPA', 11);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(109, 129, 402, 'MPA', 12);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(110, 130, 401, 'MNA', 13);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(111, 131, 402, 'MNA', 14);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(112, 132, 101, 'MNA', 15);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(113, 133, 102, 'MNA', 1);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(114, 134, 151, 'MNA', 2);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(115, 135, 152, 'MNA', 3);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(116, 136, 201, 'MNA', 4);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(117, 101, 202, 'MNA', 1);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(118, 102, 251, 'MNA', 2);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(119, 103, 252, 'MNA', 3);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(120, 104, 301, 'MNA', 4);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(121, 105, 302, 'MNA', 5);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(122, 106, 351, 'MNA', 6);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(123, 107, 352, 'MNA', 7);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(124, 108, 152, 'MNA', 8);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(125, 106, 201, 'MNA', 9);

SELECT * FROM Candidate_Position;

INSERT INTO Family_Member_Record (MEMBERID, GENDER, CNIC, DATEOFBIRTH, FAMILY_ID, VOTER_ID) 
SELECT  
    15 + ROW_NUMBER() OVER (ORDER BY V.VOTERID) AS MEMBERID, 
    V.GENDER, 
    V.CNIC, 
    V.DATEOFBIRTH, 
    V.FAMILY_ID, 
    V.VOTERID AS VOTER_ID 
FROM Voter V 
WHERE V.FAMILY_ID IS NOT NULL 
AND V.VOTERID NOT IN (SELECT VOTER_ID FROM Family_Member_Record);

select * from candidate_position where pollingstationid=151 or pollingstationid=402;

    select * from polling_station;

    select * from constituency;

select * from candidate_position where pollingstationid=101;

select * from candidate_position where pollingstationid=9;

select * from candidate_position where pollingstationid=52;

select * from candidate_position where pollingstationid=9;

select * from candidate_position where pollingstationid=402;

select * from candidate_position where pollingstationid=152;

select * from candidate_position where pollingstationid=102;

select * from candidate_position where pollingstationid=5;

select * from candidate_position where pollingstationid=401;

select * from candidate_position where pollingstationid=55;

select * from candidate_position where pollingstationid=401;

select * from candidate_position where pollingstationid=201;

select * from candidate_position where pollingstationid=101;

select * from candidate_position where pollingstationid=8;

select * from candidate_position where pollingstationid=58;

select * from candidate_position where pollingstationid=401;

select * from candidate_position where pollingstationid=252;

select * from candidate_position where pollingstationid=102;

select * from candidate_position where pollingstationid=10;

select * from candidate_position where pollingstationid=54;

INSERT  
  INTO vote (VOTEID, VOTERID, CONSTITUENCYID, POLLINGSTATIONID, ELECTIONID, CANDIDATEID, VERIFIED, VOTETYPE, VOTEDATETIME) 
    VALUES (51, 26, 17, 401, 24, 113, 'Yes', 'General', TIMESTAMP '2024-07-20 09:15:00');

insert  INTO vote (VOTEID, VOTERID, CONSTITUENCYID, POLLINGSTATIONID, ELECTIONID, CANDIDATEID, VERIFIED, VOTETYPE, VOTEDATETIME) 
    VALUES (52, 26, 34, 401, 24, 130, 'Yes', 'General', TIMESTAMP '2024-07-20 09:15:00');

insert INTO vote (VOTEID, VOTERID, CONSTITUENCYID, POLLINGSTATIONID, ELECTIONID, CANDIDATEID, VERIFIED, VOTETYPE, VOTEDATETIME) 
    VALUES (53, 27, 12, 151, 24, 103, 'Yes', 'General', TIMESTAMP '2024-07-20 09:15:00') 
;

insert INTO vote (VOTEID, VOTERID, CONSTITUENCYID, POLLINGSTATIONID, ELECTIONID, CANDIDATEID, VERIFIED, VOTETYPE, VOTEDATETIME) 
    VALUES (55, 28, 11, 101, 24, 115, 'Yes', 'General', TIMESTAMP '2024-07-20 09:15:00') 
 ;

insert  INTO vote (VOTEID, VOTERID, CONSTITUENCYID, POLLINGSTATIONID, ELECTIONID, CANDIDATEID, VERIFIED, VOTETYPE, VOTEDATETIME) 
    VALUES (54, 27, 29, 151, 24, 131, 'Yes', 'General', TIMESTAMP '2024-07-20 09:15:00') 
;

select * from polling_station;

 insert INTO vote (VOTEID, VOTERID, CONSTITUENCYID, POLLINGSTATIONID, ELECTIONID, CANDIDATEID, VERIFIED, VOTETYPE, VOTEDATETIME) 
    VALUES (56, 28, 28, 101, 24, 132, 'Yes', 'General', TIMESTAMP '2024-07-20 09:15:00') 
;

 insert INTO vote (VOTEID, VOTERID, CONSTITUENCYID, POLLINGSTATIONID, ELECTIONID, CANDIDATEID, VERIFIED, VOTETYPE, VOTEDATETIME) 
    VALUES (57, 29, 5, 9, 24, 134, 'Yes', 'General', TIMESTAMP '2024-07-20 09:15:00') 
;

insert  INTO vote (VOTEID, VOTERID, CONSTITUENCYID, POLLINGSTATIONID, ELECTIONID, CANDIDATEID, VERIFIED, VOTETYPE, VOTEDATETIME) 
    VALUES (58, 29, 22, 9, 24, 136, 'Yes', 'General', TIMESTAMP '2024-07-20 09:15:00') 
;

insert  INTO vote (VOTEID, VOTERID, CONSTITUENCYID, POLLINGSTATIONID, ELECTIONID, CANDIDATEID, VERIFIED, VOTETYPE, VOTEDATETIME) 
    VALUES (59, 30, 6, 52, 24, 109, 'Yes', 'General', TIMESTAMP '2024-07-20 09:15:00') 
;

insert  INTO vote (VOTEID, VOTERID, CONSTITUENCYID, POLLINGSTATIONID, ELECTIONID, CANDIDATEID, VERIFIED, VOTETYPE, VOTEDATETIME) 
    VALUES (61, 31, 17, 402, 24, 114, 'Yes', 'General', TIMESTAMP '2024-07-20 09:15:00') 
;

insert  INTO vote (VOTEID, VOTERID, CONSTITUENCYID, POLLINGSTATIONID, ELECTIONID, CANDIDATEID, VERIFIED, VOTETYPE, VOTEDATETIME) 
    VALUES (60, 30, 23, 52, 24, 112, 'Yes', 'General', TIMESTAMP '2024-07-20 09:15:00') 
;

insert  INTO vote (VOTEID, VOTERID, CONSTITUENCYID, POLLINGSTATIONID, ELECTIONID, CANDIDATEID, VERIFIED, VOTETYPE, VOTEDATETIME) 
    VALUES (64, 32, 29, 152, 24, 108, 'Yes', 'General', TIMESTAMP '2024-07-20 09:15:00') 
;

 insert INTO vote (VOTEID, VOTERID, CONSTITUENCYID, POLLINGSTATIONID, ELECTIONID, CANDIDATEID, VERIFIED, VOTETYPE, VOTEDATETIME) 
    VALUES (62, 31, 34, 402, 24, 131, 'Yes', 'General', TIMESTAMP '2024-07-20 09:15:00') 
;

 insert INTO vote (VOTEID, VOTERID, CONSTITUENCYID, POLLINGSTATIONID, ELECTIONID, CANDIDATEID, VERIFIED, VOTETYPE, VOTEDATETIME) 
    VALUES (63, 32, 12, 152, 24, 104, 'Yes', 'General', TIMESTAMP '2024-07-20 09:15:00') 
;

insert  INTO vote (VOTEID, VOTERID, CONSTITUENCYID, POLLINGSTATIONID, ELECTIONID, CANDIDATEID, VERIFIED, VOTETYPE, VOTEDATETIME) 
    VALUES (65, 33, 11, 102, 24, 102, 'Yes', 'General', TIMESTAMP '2024-07-20 09:15:00') 
;

 insert   INTO vote (VOTEID, VOTERID, CONSTITUENCYID, POLLINGSTATIONID, ELECTIONID, CANDIDATEID, VERIFIED, VOTETYPE, VOTEDATETIME) 
    VALUES (66, 33, 28, 102, 24, 133, 'Yes', 'General', TIMESTAMP '2024-07-20 09:15:00');

insert  INTO vote (VOTEID, VOTERID, CONSTITUENCYID, POLLINGSTATIONID, ELECTIONID, CANDIDATEID, VERIFIED, VOTETYPE, VOTEDATETIME) 
    VALUES (67, 34, 3, 5, 24, 117, 'Yes', 'General', TIMESTAMP '2024-07-20 09:15:00');

insert  INTO vote (VOTEID, VOTERID, CONSTITUENCYID, POLLINGSTATIONID, ELECTIONID, CANDIDATEID, VERIFIED, VOTETYPE, VOTEDATETIME) 
    VALUES (68, 34, 20, 5, 24, 119, 'Yes', 'General', TIMESTAMP '2024-07-20 09:15:00');

 insert INTO vote (VOTEID, VOTERID, CONSTITUENCYID, POLLINGSTATIONID, ELECTIONID, CANDIDATEID, VERIFIED, VOTETYPE, VOTEDATETIME) 
    VALUES (69, 35, 8, 55, 24, 121, 'Yes', 'General', TIMESTAMP '2024-07-20 09:15:00');

insert    INTO vote (VOTEID, VOTERID, CONSTITUENCYID, POLLINGSTATIONID, ELECTIONID, CANDIDATEID, VERIFIED, VOTETYPE, VOTEDATETIME) 
    VALUES (70, 35, 25, 55, 24, 123, 'No', 'General', TIMESTAMP '2024-07-20 09:15:00');

insert    INTO vote (VOTEID, VOTERID, CONSTITUENCYID, POLLINGSTATIONID, ELECTIONID, CANDIDATEID, VERIFIED, VOTETYPE, VOTEDATETIME) 
     VALUES (71, 36, 17, 401, 24, 113, 'Yes', 'General', TIMESTAMP '2024-07-20 09:15:00');

insert    INTO vote (VOTEID, VOTERID, CONSTITUENCYID, POLLINGSTATIONID, ELECTIONID, CANDIDATEID, VERIFIED, VOTETYPE, VOTEDATETIME) 
    VALUES (72, 36, 34, 401, 24, 130, 'Yes', 'General', TIMESTAMP '2024-07-20 09:15:00');

insert  INTO vote (VOTEID, VOTERID, CONSTITUENCYID, POLLINGSTATIONID, ELECTIONID, CANDIDATEID, VERIFIED, VOTETYPE, VOTEDATETIME) 
    VALUES (73, 37, 13, 201, 24, 105, 'Yes', 'General', TIMESTAMP '2024-07-20 09:15:00');

 insert INTO vote (VOTEID, VOTERID, CONSTITUENCYID, POLLINGSTATIONID, ELECTIONID, CANDIDATEID, VERIFIED, VOTETYPE, VOTEDATETIME) 
    VALUES (74, 37, 30, 201, 24, 136, 'Yes', 'General', TIMESTAMP '2024-07-20 09:15:00');

 insert INTO vote (VOTEID, VOTERID, CONSTITUENCYID, POLLINGSTATIONID, ELECTIONID, CANDIDATEID, VERIFIED, VOTETYPE, VOTEDATETIME) 
    VALUES (75, 38, 11, 101, 24, 101, 'Yes', 'General', TIMESTAMP '2024-07-20 09:15:00');

 insert INTO vote (VOTEID, VOTERID, CONSTITUENCYID, POLLINGSTATIONID, ELECTIONID, CANDIDATEID, VERIFIED, VOTETYPE, VOTEDATETIME) 
    VALUES (76, 38, 28, 101, 24, 117, 'Yes', 'General', TIMESTAMP '2024-07-20 09:15:00');

 insert INTO vote (VOTEID, VOTERID, CONSTITUENCYID, POLLINGSTATIONID, ELECTIONID, CANDIDATEID, VERIFIED, VOTETYPE, VOTEDATETIME) 
    VALUES (77, 39, 4, 8, 24, 121, 'No', 'General', TIMESTAMP '2024-07-20 09:15:00');

insert  INTO vote (VOTEID, VOTERID, CONSTITUENCYID, POLLINGSTATIONID, ELECTIONID, CANDIDATEID, VERIFIED, VOTETYPE, VOTEDATETIME) 
    VALUES (78, 39, 21, 8, 24, 132, 'Yes', 'General', TIMESTAMP '2024-07-20 09:15:00');

 insert INTO vote (VOTEID, VOTERID, CONSTITUENCYID, POLLINGSTATIONID, ELECTIONID, CANDIDATEID, VERIFIED, VOTETYPE, VOTEDATETIME) 
    VALUES (79, 40, 9, 58, 24, 133, 'Yes', 'General', TIMESTAMP '2024-07-20 09:15:00');

 insert INTO vote (VOTEID, VOTERID, CONSTITUENCYID, POLLINGSTATIONID, ELECTIONID, CANDIDATEID, VERIFIED, VOTETYPE, VOTEDATETIME) 
    VALUES (81, 41, 17, 401, 24, 128, 'Yes', 'General', TIMESTAMP '2024-07-20 09:15:00');

  insert INTO vote (VOTEID, VOTERID, CONSTITUENCYID, POLLINGSTATIONID, ELECTIONID, CANDIDATEID, VERIFIED, VOTETYPE, VOTEDATETIME) 
    VALUES (82, 41, 34, 401, 24, 130, 'Yes', 'General', TIMESTAMP '2024-07-20 09:15:00');

  insert INTO vote (VOTEID, VOTERID, CONSTITUENCYID, POLLINGSTATIONID, ELECTIONID, CANDIDATEID, VERIFIED, VOTETYPE, VOTEDATETIME) 
    VALUES (83, 42, 14, 252, 24, 123, 'Yes', 'General', TIMESTAMP '2024-07-20 09:15:00');

 insert INTO vote (VOTEID, VOTERID, CONSTITUENCYID, POLLINGSTATIONID, ELECTIONID, CANDIDATEID, VERIFIED, VOTETYPE, VOTEDATETIME) 
    VALUES (84, 42, 31, 252, 24, 103, 'Yes', 'General', TIMESTAMP '2024-07-20 09:15:00');

 insert INTO vote (VOTEID, VOTERID, CONSTITUENCYID, POLLINGSTATIONID, ELECTIONID, CANDIDATEID, VERIFIED, VOTETYPE, VOTEDATETIME) 
    VALUES (85, 43, 11, 102, 24, 102, 'Yes', 'General', TIMESTAMP '2024-07-20 09:15:00');

 insert INTO vote (VOTEID, VOTERID, CONSTITUENCYID, POLLINGSTATIONID, ELECTIONID, CANDIDATEID, VERIFIED, VOTETYPE, VOTEDATETIME) 
    VALUES (86, 43, 28, 102, 24, 133, 'Yes', 'General', TIMESTAMP '2024-07-20 09:15:00');

 insert INTO vote (VOTEID, VOTERID, CONSTITUENCYID, POLLINGSTATIONID, ELECTIONID, CANDIDATEID, VERIFIED, VOTETYPE, VOTEDATETIME) 
    VALUES (87, 44, 5, 10, 24, 101, 'Yes', 'General', TIMESTAMP '2024-07-20 09:15:00');

 insert INTO vote (VOTEID, VOTERID, CONSTITUENCYID, POLLINGSTATIONID, ELECTIONID, CANDIDATEID, VERIFIED, VOTETYPE, VOTEDATETIME) 
    VALUES (88, 44, 22, 10, 24, 103, 'Yes', 'General', TIMESTAMP '2024-07-20 09:15:00');

 insert INTO vote (VOTEID, VOTERID, CONSTITUENCYID, POLLINGSTATIONID, ELECTIONID, CANDIDATEID, VERIFIED, VOTETYPE, VOTEDATETIME) 
    VALUES (89, 45, 7, 54, 24, 118, 'Yes', 'General', TIMESTAMP '2024-07-20 09:15:00');

 insert     INTO vote (VOTEID, VOTERID, CONSTITUENCYID, POLLINGSTATIONID, ELECTIONID, CANDIDATEID, VERIFIED, VOTETYPE, VOTEDATETIME) 
    VALUES (90, 45, 24, 54, 24, 120, 'Yes', 'General', TIMESTAMP '2024-07-20 09:15:00');

select * from vote;

select * from vote where voteid>50;

select * from vote where voteid<50;

select * from voter;

select * from vote where voteid<50;

select * from candidate_position where pollingstationid=401;

UPDATE Vote 
SET CandidateID = 113 
WHERE VoteID = 3;

INSERT INTO Vote (VoteID, VoterID, ConstituencyID, PollingStationID, ElectionID, CandidateID, Verified, VoteType, VoteDateTime) 
values( 26, 3, 34, 401, 24, 130, 'Yes', 'General', TIMESTAMP '2024-07-20 08:30:00');

select * from vote where voteid<50;

select * from candidate_position where pollingstationid=151;

UPDATE Vote 
SET CandidateID = 103 
WHERE VoteID = 4;

UPDATE Vote 
SET CandidateID = 103 
WHERE VoteID = 4;

select * from candidate_position where pollingstationid=151;

INSERT INTO Vote (VoteID, VoterID, ConstituencyID, PollingStationID, ElectionID, CandidateID, Verified, VoteType, VoteDateTime) 
values( 27, 4, 29, 151, 24, 134, 'Yes', 'General', TIMESTAMP '2024-07-20 08:30:00');

select * from candidate_position where pollingstationid=101;

UPDATE Vote 
SET CandidateID = 101 
WHERE VoteID = 5;

INSERT INTO Vote (VoteID, VoterID, ConstituencyID, PollingStationID, ElectionID, CandidateID, Verified, VoteType, VoteDateTime) 
values( 28, 5, 28, 101, 24, 132, 'Yes', 'General', TIMESTAMP '2024-07-20 08:30:00');

UPDATE Vote 
SET CandidateID = 101 
WHERE VoteID = 6;

INSERT INTO Vote (VoteID, VoterID, ConstituencyID, PollingStationID, ElectionID, CandidateID, Verified, VoteType, VoteDateTime) 
values( 29, 6, 19, 10, 24, 104, 'Yes', 'General', TIMESTAMP '2024-07-20 08:30:00');

UPDATE Vote 
SET CandidateID = 125 
WHERE VoteID = 7;

INSERT INTO Vote (VoteID, VoterID, ConstituencyID, PollingStationID, ElectionID, CandidateID, Verified, VoteType, VoteDateTime) 
values( 30, 7, 24, 56, 24, 128, 'Yes', 'General', TIMESTAMP '2024-07-20 08:30:00');

UPDATE Vote 
SET CandidateID = 128 
WHERE VoteID = 8;

INSERT INTO Vote (VoteID, VoterID, ConstituencyID, PollingStationID, ElectionID, CandidateID, Verified, VoteType, VoteDateTime) 
values( 31, 8, 34, 401, 24, 130, 'Yes', 'General', TIMESTAMP '2024-07-20 08:30:00');

INSERT INTO Vote (VoteID, VoterID, ConstituencyID, PollingStationID, ElectionID, CandidateID, Verified, VoteType, VoteDateTime) 
values( 32, 9, 30, 201, 24, 108, 'Yes', 'General', TIMESTAMP '2024-07-20 08:30:00');

UPDATE Vote 
SET CandidateID = 119, POLLINGSTATIONID=201 
WHERE VoteID = 9;

UPDATE Vote 
SET CandidateID = 102 
WHERE VoteID = 10;

INSERT INTO Vote (VoteID, VoterID, ConstituencyID, PollingStationID, ElectionID, CandidateID, Verified, VoteType, VoteDateTime) 
values( 33, 10, 28, 102, 24, 133, 'Yes', 'General', TIMESTAMP '2024-07-20 08:30:00');

UPDATE Vote 
SET CandidateID = 117 
WHERE VoteID = 11;

INSERT INTO Vote (VoteID, VoterID, ConstituencyID, PollingStationID, ElectionID, CandidateID, Verified, VoteType, VoteDateTime) 
values( 34, 11, 20, 5, 24, 119, 'Yes', 'General', TIMESTAMP '2024-07-20 08:30:00');

UPDATE Vote 
SET CandidateID = 121 
WHERE VoteID = 12;

INSERT INTO Vote (VoteID, VoterID, ConstituencyID, PollingStationID, ElectionID, CandidateID, Verified, VoteType, VoteDateTime) 
values( 35, 12, 25, 55, 24, 124, 'Yes', 'General', TIMESTAMP '2024-07-20 08:30:00');

UPDATE Vote 
SET CandidateID = 114 
WHERE VoteID = 13;

INSERT INTO Vote (VoteID, VoterID, ConstituencyID, PollingStationID, ElectionID, CandidateID, Verified, VoteType, VoteDateTime) 
values( 36, 13, 34, 402, 24, 131, 'Yes', 'General', TIMESTAMP '2024-07-20 08:30:00');

UPDATE Vote 
SET CandidateID = 107, pollingstationid=251 
WHERE VoteID = 14;

INSERT INTO Vote (VoteID, VoterID, ConstituencyID, PollingStationID, ElectionID, CandidateID, Verified, VoteType, VoteDateTime) 
values( 37, 14, 31, 251, 24, 102, 'Yes', 'General', TIMESTAMP '2024-07-20 08:30:00');

UPDATE Vote 
SET CandidateID = 115 
WHERE VoteID = 15;

INSERT INTO Vote (VoteID, VoterID, ConstituencyID, PollingStationID, ElectionID, CandidateID, Verified, VoteType, VoteDateTime) 
values( 38, 15, 28, 101, 24, 132, 'Yes', 'General', TIMESTAMP '2024-07-20 08:30:00');

UPDATE Vote 
SET CandidateID = 129 
WHERE VoteID = 16;

INSERT INTO Vote (VoteID, VoterID, ConstituencyID, PollingStationID, ElectionID, CandidateID, Verified, VoteType, VoteDateTime) 
values( 39, 16, 21, 8, 24, 132, 'Yes', 'General', TIMESTAMP '2024-07-20 08:30:00');

UPDATE Vote 
SET CandidateID = 134, pollingstationid=58 
WHERE VoteID = 17;

INSERT INTO Vote (VoteID, VoterID, ConstituencyID, PollingStationID, ElectionID, CandidateID, Verified, VoteType, VoteDateTime) 
values( 40, 17, 26, 58, 24, 135, 'Yes', 'General', TIMESTAMP '2024-07-20 08:30:00');

UPDATE Vote 
SET CandidateID = 128 
WHERE VoteID = 18;

INSERT INTO Vote (VoteID, VoterID, ConstituencyID, PollingStationID, ElectionID, CandidateID, Verified, VoteType, VoteDateTime) 
values( 41, 18, 34, 401, 24, 130, 'Yes', 'General', TIMESTAMP '2024-07-20 08:30:00');

UPDATE Vote 
SET CandidateID = 126 
WHERE VoteID = 19;

INSERT INTO Vote (VoteID, VoterID, ConstituencyID, PollingStationID, ElectionID, CandidateID, Verified, VoteType, VoteDateTime) 
values( 42, 19, 33, 351, 24, 106, 'Yes', 'General', TIMESTAMP '2024-07-20 08:30:00');

UPDATE Vote 
SET CandidateID = 102 
WHERE VoteID = 20;

INSERT INTO Vote (VoteID, VoterID, ConstituencyID, PollingStationID, ElectionID, CandidateID, Verified, VoteType, VoteDateTime) 
values( 43, 20, 28, 102, 24, 133, 'No', 'General', TIMESTAMP '2024-07-20 08:30:00');

UPDATE Vote 
SET CandidateID = 133 
WHERE VoteID = 21;

INSERT INTO Vote (VoteID, VoterID, ConstituencyID, PollingStationID, ElectionID, CandidateID, Verified, VoteType, VoteDateTime) 
values( 44, 21, 26, 9, 24, 136, 'No', 'General', TIMESTAMP '2024-07-20 08:30:00');

UPDATE Vote 
SET CandidateID = 114 
WHERE VoteID = 23;

INSERT INTO Vote (VoteID, VoterID, ConstituencyID, PollingStationID, ElectionID, CandidateID, Verified, VoteType, VoteDateTime) 
values( 45, 23, 34, 402, 24, 131, 'Yes', 'General', TIMESTAMP '2024-07-20 08:30:00');

UPDATE Vote 
SET CandidateID = 101 
WHERE VoteID = 25;

INSERT INTO Vote (VoteID, VoterID, ConstituencyID, PollingStationID, ElectionID, CandidateID, Verified, VoteType, VoteDateTime) 
values( 46, 25, 28, 101, 24, 132, 'Yes', 'General', TIMESTAMP '2024-07-20 08:30:00');

select * from candidate_position;

drop table candidate_position;

CREATE TABLE Candidate_Position ( 
    candidate_position_id INT PRIMARY KEY, 
    candidate_id INT, 
    pollingstationid INT, 
    position VARCHAR2(3), -- This can be 'MPA' or 'MNA' 
    party_id INT, 
    FOREIGN KEY (candidate_id) REFERENCES Candidate(candidate_id), 
    FOREIGN KEY (pollingstationid) REFERENCES Polling_Station(pollingstationid), 
    FOREIGN KEY (party_id) REFERENCES Political_Party(party_id) 
);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) 
VALUES (1, 101, 1, 'MPA', 1);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) 
VALUES (2, 104, 1, 'MPA', 4);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) 
VALUES (3, 103, 1, 'MNA', 3);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) 
VALUES (4, 104, 1, 'MNA', 4);

INSERT ALL  
    INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES (5, 105, 2, 'MPA', 5) 
    INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES (6, 106, 2, 'MPA', 6) 
    INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES (7, 105, 2, 'MNA', 5) 
    INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES (8, 108, 2, 'MNA', 8) 
SELECT * FROM dual;

INSERT ALL  
    INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES (9, 109, 3, 'MPA', 9) 
    INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES (10, 111, 3, 'MPA', 11) 
    INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES (11, 111, 3, 'MNA', 11) 
    INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES (12, 112, 3, 'MNA', 12) 
SELECT * FROM dual;

INSERT ALL  
    INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES (13, 113, 4, 'MPA', 13) 
    INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES (14, 114, 4, 'MPA', 14) 
    INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES (15, 115, 4, 'MNA', 15) 
    INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES (16, 116, 4, 'MNA', 1) 
SELECT * FROM dual;

INSERT ALL  
    INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES (17, 117, 5, 'MPA', 2) 
    INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES (18, 118, 5, 'MPA', 1) 
    INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES (19, 119, 5, 'MNA', 2) 
    INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES (20, 120, 5, 'MNA', 3) 
SELECT * FROM dual;

INSERT ALL  
    INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES (21, 121, 6, 'MPA', 4) 
    INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES (22, 122, 6, 'MPA', 5) 
    INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES (23, 123, 6, 'MNA', 6) 
    INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES (24, 124, 6, 'MNA', 7) 
SELECT * FROM dual;

INSERT ALL  
    INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES (25, 125, 7, 'MPA', 8) 
    INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES (26, 126, 7, 'MPA', 9) 
    INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES (27, 127, 7, 'MNA', 10) 
    INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES (28, 128, 7, 'MNA', 11) 
SELECT * FROM dual;

INSERT ALL  
    INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES (29, 129, 8, 'MPA', 12) 
    INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES (30, 130, 8, 'MPA', 13) 
    INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES (31, 131, 8, 'MNA', 14) 
    INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES (32, 132, 8, 'MNA', 15) 
SELECT * FROM dual;

INSERT ALL  
    INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES (33, 133, 9, 'MPA', 1) 
    INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES (34, 134, 9, 'MPA', 2) 
    INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES (35, 135, 9, 'MNA', 3) 
    INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES (36, 136, 9, 'MNA', 4) 
SELECT * FROM dual;

INSERT ALL  
    INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES (37, 101, 10, 'MPA', 1) 
    INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES (38, 102, 10, 'MPA', 2) 
    INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES (39, 103, 10, 'MNA', 3) 
    INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES (40, 104, 10, 'MNA', 4) 
SELECT * FROM dual;

INSERT ALL  
    INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES (41, 105, 51, 'MPA', 5) 
    INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES (42, 106, 51, 'MPA', 6) 
    INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES (43, 107, 51, 'MNA', 7) 
    INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES (44, 108, 51, 'MNA', 8) 
SELECT * FROM dual;

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id)  
VALUES (45, 109, 52, 'MPA', 9);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(46, 110, 52, 'MPA', 10);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(47, 111, 52, 'MNA', 11);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(48, 112, 52, 'MNA', 12);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(49, 113, 53, 'MPA', 13);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(50, 114, 53, 'MPA', 14);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(51, 115, 53, 'MNA', 15);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(52, 116, 53, 'MNA', 1);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(53, 117, 54, 'MPA', 2);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(54, 118, 54, 'MPA', 1);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(55, 119, 54, 'MNA', 2);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(56, 120, 54, 'MNA', 3);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(57, 121, 55, 'MPA', 4);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(58, 122, 55, 'MPA', 5);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(59, 123, 55, 'MNA', 6);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(60, 124, 55, 'MNA', 7);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(61, 125, 56, 'MPA', 8);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(62, 126, 56, 'MPA', 9);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(63, 127, 56, 'MNA', 10);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(64, 128, 56, 'MNA', 11);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(65, 129, 57, 'MPA', 12);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(66, 130, 57, 'MPA', 13);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(67, 131, 57, 'MNA', 14);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(68, 132, 57, 'MNA', 15);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(69, 133, 58, 'MPA', 1);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(70, 134, 58, 'MPA', 2);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(71, 135, 58, 'MNA', 3);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(72, 136, 58, 'MNA', 4);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(73, 101, 59, 'MPA', 1);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(74, 102, 59, 'MPA', 2);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(75, 103, 59, 'MNA', 3);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(76, 104, 59, 'MNA', 4);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(77, 105, 60, 'MPA', 5);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(78, 106, 60, 'MPA', 6);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(79, 107, 60, 'MNA', 7);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(80, 108, 60, 'MNA', 8);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(81, 101, 101, 'MPA', 1);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(82, 102, 102, 'MPA', 2);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(83, 103, 151, 'MPA', 3);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(84, 104, 152, 'MPA', 4);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(85, 105, 201, 'MPA', 5);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(86, 106, 202, 'MPA', 6);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(87, 107, 251, 'MPA', 7);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(88, 108, 252, 'MPA', 8);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(89, 109, 301, 'MPA', 9);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(90, 110, 302, 'MPA', 10);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(91, 111, 351, 'MPA', 11);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(92, 112, 352, 'MPA', 12);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(93, 113, 401, 'MPA', 13);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(94, 114, 402, 'MPA', 14);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(95, 115, 101, 'MPA', 15);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(96, 116, 102, 'MPA', 1);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(97, 117, 101, 'MNA', 2);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(98, 118, 151, 'MPA', 1);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(99, 119, 152, 'MPA', 2);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(100, 120, 201, 'MPA', 3);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(101, 121, 202, 'MPA', 4);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(102, 122, 251, 'MPA', 5);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(103, 123, 252, 'MPA', 6);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(104, 124, 301, 'MPA', 7);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(105, 125, 302, 'MPA', 8);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(106, 126, 351, 'MPA', 9);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(107, 127, 352, 'MPA', 10);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(108, 128, 401, 'MPA', 11);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(109, 129, 402, 'MPA', 12);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(110, 130, 401, 'MNA', 13);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(111, 131, 402, 'MNA', 14);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(112, 132, 101, 'MNA', 15);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(113, 133, 102, 'MNA', 1);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(114, 134, 151, 'MNA', 2);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(115, 135, 152, 'MNA', 3);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(116, 136, 201, 'MNA', 4);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(117, 101, 202, 'MNA', 1);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(118, 102, 251, 'MNA', 2);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(119, 103, 252, 'MNA', 3);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(120, 104, 301, 'MNA', 4);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(121, 105, 302, 'MNA', 5);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(122, 106, 351, 'MNA', 6);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(123, 107, 352, 'MNA', 7);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(124, 108, 152, 'MNA', 8);

INSERT INTO Candidate_Position (candidate_position_id, candidate_id, pollingstationid, position, party_id) VALUES 
(125, 106, 201, 'MNA', 9);

select * from candidate_position;

select * from candidate_position;

INSERT ALL 
    INTO Returning_Officer (returningOfficerID, Name, Email, ContactNumber, ConstituencyID) VALUES (1, 'Muhammad Ali', 'muhammad.ali@example.com', '0300-1234567', 1) 
    INTO Returning_Officer (returningOfficerID, Name, Email, ContactNumber, ConstituencyID) VALUES (2, 'Ahmed Khan', 'ahmed.khan@example.com', '0321-2345678', 2) 
    INTO Returning_Officer (returningOfficerID, Name, Email, ContactNumber, ConstituencyID) VALUES (3, 'Aamir Shah', 'aamir.shah@example.com', '0333-3456789', 3) 
    INTO Returning_Officer (returningOfficerID, Name, Email, ContactNumber, ConstituencyID) VALUES (4, 'Farhan Mahmood', 'farhan.mahmood@example.com', '0322-4567890', 4) 
    INTO Returning_Officer (returningOfficerID, Name, Email, ContactNumber, ConstituencyID) VALUES (5, 'Saeed Ahmed', 'saeed.ahmed@example.com', '0313-5678901', 5) 
    INTO Returning_Officer (returningOfficerID, Name, Email, ContactNumber, ConstituencyID) VALUES (6, 'Irfan Khan', 'irfan.khan@example.com', '0311-6789012', 6) 
    INTO Returning_Officer (returningOfficerID, Name, Email, ContactNumber, ConstituencyID) VALUES (7, 'Nadeem Malik', 'nadeem.malik@example.com', '0300-7890123', 7) 
    INTO Returning_Officer (returningOfficerID, Name, Email, ContactNumber, ConstituencyID) VALUES (8, 'Khalid Mehmood', 'khalid.mehmood@example.com', '0321-8901234', 8) 
    INTO Returning_Officer (returningOfficerID, Name, Email, ContactNumber, ConstituencyID) VALUES (9, 'Tariq Mahmood', 'tariq.mahmood@example.com', '0333-9012345', 9) 
    INTO Returning_Officer (returningOfficerID, Name, Email, ContactNumber, ConstituencyID) VALUES (10, 'Zubair Ali', 'zubair.ali@example.com', '0322-0123456', 10) 
    INTO Returning_Officer (returningOfficerID, Name, Email, ContactNumber, ConstituencyID) VALUES (11, 'Faisal Khan', 'faisal.khan@example.com', '0313-1234567', 11) 
    INTO Returning_Officer (returningOfficerID, Name, Email, ContactNumber, ConstituencyID) VALUES (12, 'Usman Haider', 'usman.haider@example.com', '0311-2345678', 12) 
    INTO Returning_Officer (returningOfficerID, Name, Email, ContactNumber, ConstituencyID) VALUES (13, 'Javed Akhtar', 'javed.akhtar@example.com', '0300-3456789', 13) 
    INTO Returning_Officer (returningOfficerID, Name, Email, ContactNumber, ConstituencyID) VALUES (14, 'Arif Siddiqui', 'arif.siddiqui@example.com', '0321-4567890', 14) 
    INTO Returning_Officer (returningOfficerID, Name, Email, ContactNumber, ConstituencyID) VALUES (15, 'Asadullah Khan', 'asadullah.khan@example.com', '0333-5678901', 15) 
    INTO Returning_Officer (returningOfficerID, Name, Email, ContactNumber, ConstituencyID) VALUES (16, 'Imran Hassan', 'imran.hassan@example.com', '0322-6789012', 16) 
    INTO Returning_Officer (returningOfficerID, Name, Email, ContactNumber, ConstituencyID) VALUES (17, 'Kamran Ali', 'kamran.ali@example.com', '0313-7890123', 17) 
    INTO Returning_Officer (returningOfficerID, Name, Email, ContactNumber, ConstituencyID) VALUES (18, 'Noman Akram', 'noman.akram@example.com', '0311-8901234', 18) 
    INTO Returning_Officer (returningOfficerID, Name, Email, ContactNumber, ConstituencyID) VALUES (19, 'Rashid Mahmood', 'rashid.mahmood@example.com', '0300-9012345', 19) 
    INTO Returning_Officer (returningOfficerID, Name, Email, ContactNumber, ConstituencyID) VALUES (20, 'Salman Khan', 'salman.khan@example.com', '0321-0123456', 20) 
    INTO Returning_Officer (returningOfficerID, Name, Email, ContactNumber, ConstituencyID) VALUES (21, 'Tahir Mehmood', 'tahir.mehmood@example.com', '0333-1234567', 21) 
    INTO Returning_Officer (returningOfficerID, Name, Email, ContactNumber, ConstituencyID) VALUES (22, 'Waqar Ahmad', 'waqar.ahmad@example.com', '0322-2345678', 22) 
    INTO Returning_Officer (returningOfficerID, Name, Email, ContactNumber, ConstituencyID) VALUES (23, 'Yasir Khan', 'yasir.khan@example.com', '0313-3456789', 23) 
    INTO Returning_Officer (returningOfficerID, Name, Email, ContactNumber, ConstituencyID) VALUES (24, 'Ziaullah Shah', 'ziaullah.shah@example.com', '0311-4567890', 24) 
    INTO Returning_Officer (returningOfficerID, Name, Email, ContactNumber, ConstituencyID) VALUES (25, 'Abdul Rehman', 'abdul.rehman@example.com', '0300-5678901', 25) 
    INTO Returning_Officer (returningOfficerID, Name, Email, ContactNumber, ConstituencyID) VALUES (26, 'Bilal Khan', 'bilal.khan@example.com', '0321-6789012', 26) 
    INTO Returning_Officer (returningOfficerID, Name, Email, ContactNumber, ConstituencyID) VALUES (27, 'Ejaz Ahmed', 'ejaz.ahmed@example.com', '0333-7890123', 27) 
    INTO Returning_Officer (returningOfficerID, Name, Email, ContactNumber, ConstituencyID) VALUES (28, 'Ghulam Mustafa', 'ghulam.mustafa@example.com', '0322-8901234', 28) 
    INTO Returning_Officer (returningOfficerID, Name, Email, ContactNumber, ConstituencyID) VALUES (29, 'Haroon Khan', 'haroon.khan@example.com', '0313-9012345', 29) 
    INTO Returning_Officer (returningOfficerID, Name, Email, ContactNumber, ConstituencyID) VALUES (30, 'Jawad Hassan', 'jawad.hassan@example.com', '0311-0123456', 30) 
    INTO Returning_Officer (returningOfficerID, Name, Email, ContactNumber, ConstituencyID) VALUES (31, 'Kashif Ali', 'kashif.ali@example.com', '0300-1234567', 31) 
    INTO Returning_Officer (returningOfficerID, Name, Email, ContactNumber, ConstituencyID) VALUES (32, 'Murtaza Ahmed', 'murtaza.ahmed@example.com', '0321-2345678', 32) 
    INTO Returning_Officer (returningOfficerID, Name, Email, ContactNumber, ConstituencyID) VALUES (33, 'Nauman Khan', 'nauman.khan@example.com', '0333-3456789', 33) 
    INTO Returning_Officer (returningOfficerID, Name, Email, ContactNumber, ConstituencyID) VALUES (34, 'Omar Farooq', 'omar.farooq@example.com', '0322-4567890', 34) 
SELECT 1 FROM DUAL;

CREATE SEQUENCE Polling_Station_Result_seq START WITH 1 INCREMENT BY 1;

COMMIT;

COMMIT;

DECLARE 
    v_CandidateID Vote.CandidateID%TYPE; 
    v_ConstituencyID Vote.ConstituencyID%TYPE; 
    v_ElectionID Vote.ElectionID%TYPE; 
    v_VotesReceived NUMBER; 
 
BEGIN 
    FOR rec IN ( 
        SELECT  
            v.ConstituencyID, 
            v.CandidateID, 
            c.Name AS CandidateName, 
            v.ElectionID, 
            COUNT(*) AS VotesReceived 
        FROM  
            Vote v 
        JOIN  
            Candidate c ON v.CandidateID = c.candidate_ID 
        GROUP BY  
            v.ConstituencyID, v.CandidateID, c.Name, v.ElectionID 
    )  
    LOOP 
        -- Assign values from cursor record to variables 
        v_ConstituencyID := rec.ConstituencyID; 
        v_CandidateID := rec.CandidateID; 
        v_ElectionID := rec.ElectionID; 
        v_VotesReceived := rec.VotesReceived; 
         
        -- Insert aggregated results into Polling_Station_Result 
        INSERT INTO Polling_Station_Result ( 
            PollingStationResultID,  
            ConstituencyID,  
            CandidateName,  
            CandidateID,  
            ElectionID,  
            VotesReceived 
        ) VALUES ( 
            Polling_Station_Result_seq.NEXTVAL, -- Using the sequence for primary key 
            v_ConstituencyID, 
            rec.CandidateName, 
            v_CandidateID, 
            v_ElectionID, 
            v_VotesReceived 
        ); 
    END LOOP; 
     
    COMMIT; -- Commit the transaction 
END; 
/

select * from polling_station_result;

select * from vote where candidateid=49;

select * from vote;

select * from polling_station_result;

select * from vote where candidateid=130;

    select * from constituency;

DECLARE 
    v_CandidateID Vote.CandidateID%TYPE; 
    v_ConstituencyID Vote.ConstituencyID%TYPE; 
    v_ElectionID Vote.ElectionID%TYPE; 
    v_VotesReceived NUMBER; 
 
BEGIN 
    FOR rec IN ( 
        SELECT  
            v.ConstituencyID, 
            v.CandidateID, 
            c.Name AS CandidateName, 
            v.ElectionID, 
            COUNT(*) AS VotesReceived 
        FROM  
            Vote v 
        JOIN  
            Candidate c ON v.CandidateID = c.candidate_ID 
        GROUP BY  
            v.ConstituencyID, v.CandidateID, c.Name, v.ElectionID 
    )  
    LOOP 
        -- Assign values from cursor record to variables 
        v_ConstituencyID := rec.ConstituencyID; 
        v_CandidateID := rec.CandidateID; 
        v_ElectionID := rec.ElectionID; 
        v_VotesReceived := rec.VotesReceived; 
         
        -- Insert aggregated results into Polling_Station_Result 
        INSERT INTO Polling_Station_Result ( 
            PollingStationResultID,  
            ConstituencyID,  
            CandidateName,  
            CandidateID,  
            ElectionID,  
            VotesReceived 
        ) VALUES ( 
            Polling_Station_Result_seq.NEXTVAL, -- Using the sequence for primary key 
            v_ConstituencyID, 
            rec.CandidateName, 
            v_CandidateID, 
            v_ElectionID, 
            v_VotesReceived 
        ); 
    END LOOP; 
     
    COMMIT; -- Commit the transaction 
END; 
/

select * from polling_station_result;

select * from polling_station_result;

select * from vote where candidateid=130;

INSERT INTO Province_Assembly_Result ( 
    PA_ResultID, 
    ProvinceID, 
    ConstituencyID, 
    CandidateName, 
    CandidateID, 
    VotesReceived, 
    ResultStatus 
) 
WITH CandidateVotes AS ( 
    SELECT  
        p.ConstituencyID, 
        p.CandidateName, 
        p.CandidateID, 
        p.ElectionID, 
        v.PollingStationID, 
        MAX(p.VotesReceived) AS MaxVotes 
    FROM  
        Polling_Station_Result p 
    JOIN  
        Vote v ON p.ConstituencyID = v.ConstituencyID 
            AND p.CandidateID = v.CandidateID 
            AND p.ElectionID = v.ElectionID 
    WHERE  
        p.ConstituencyID IN ( 
            1, 2, 3, 4, 5, -- Karachi's 5 constituencies 
            51, 52, 53, 54, 55, -- Lahore's 5 constituencies 
            101, 102, -- Quetta's special cases 
            151, 152, 201, 202, 251, 252, 301, 302, 351, 352, -- Peshawar's 10 constituencies 
            401, 402 -- Islamabad's 2 constituencies 
        ) 
    GROUP BY  
        p.ConstituencyID, p.CandidateName, p.CandidateID, p.ElectionID, v.PollingStationID 
) 
SELECT  
    Polling_Station_Result_seq.NEXTVAL, -- Using the sequence for primary key 
    CASE 
        WHEN cv.ConstituencyID BETWEEN 1 AND 10 THEN 1 -- Karachi 
        WHEN cv.ConstituencyID BETWEEN 51 AND 60 THEN 2 -- Lahore 
        WHEN cv.ConstituencyID IN (101, 102) THEN 3 -- Quetta 
        WHEN cv.ConstituencyID IN (151, 152, 201, 202, 251, 252, 301, 302, 351, 352) THEN 4 -- Peshawar 
        WHEN cv.ConstituencyID IN (401, 402) THEN 5 -- Islamabad 
        ELSE NULL -- Handle any other cases 
    END AS ProvinceID, 
    cv.ConstituencyID, 
    cv.CandidateName, 
    cv.CandidateID, 
    cv.MaxVotes AS VotesReceived, 
    NULL AS ResultStatus -- Assuming ResultStatus is not applicable or known 
FROM  
    CandidateVotes cv;

select * from province_assembly_result;

select * from polling_station_result;

select * from vote;

select * from vote order by pollingstationid;

select * from vote where pollingstationid=1;

select * from vote;

select * from vote where constituencyid=1;

UPDATE Province_Assembly_Result par 
SET ResultStatus = ( 
    SELECT CASE 
               WHEN par.VotesReceived = cv.MaxVotes THEN 'Winner' 
               ELSE 'Loser' 
           END 
    FROM ( 
             SELECT 
                 p.ConstituencyID, 
                 p.CandidateID, 
                 MAX(p.VotesReceived) AS MaxVotes 
             FROM Polling_Station_Result p 
                      JOIN Vote v ON p.ConstituencyID = v.ConstituencyID 
                                  AND p.CandidateID = v.CandidateID 
                                  AND p.ElectionID = v.ElectionID 
             WHERE p.ConstituencyID = par.ConstituencyID 
             GROUP BY p.ConstituencyID, p.CandidateID 
         ) cv 
    WHERE par.ConstituencyID = cv.ConstituencyID 
      AND par.CandidateID = cv.CandidateID 
);

select * from province_assembly_result;

select * from vote where constituencyid BETWEEN 1 and 17 order by constituencyid;

SELECT DISTINCT ConstituencyID 
FROM Province_Assembly_Result 
WHERE ConstituencyID BETWEEN 1 AND 17;

select * from polling_station_result;

select * from polling_station_result where POLLINGSTATIONRESULTID>50;

select * from polling_station_result where POLLINGSTATIONRESULTID>100;

select * from polling_station_result where POLLINGSTATIONRESULTID>110;

select * from polling_station_result where CONSTITUENCYID between 1 and 17;

SELECT COUNT(DISTINCT ConstituencyID) AS TotalConstituencies 
FROM Polling_Station_Result 
WHERE ConstituencyID BETWEEN 1 AND 17;

SELECT COUNT(ConstituencyID) AS TotalConstituencies 
FROM Polling_Station_Result 
WHERE ConstituencyID BETWEEN 1 AND 17;

TRUNCATE TABLE province_assembly_result


SELECT * FROM Constituency;

SELECT * FROM Voter;

SELECT * FROM Polling_Station_Result;

SELECT * FROM Province_Assembly_Result;

SELECT * FROM Polling_Station_Result WHERE CONSTITUENCYID =9;

SELECT * FROM Candidate_Position;

SELECT * FROM Candidate;

INSERT INTO Province_Assembly_Result (PA_ResultID, ProvinceID, ConstituencyID, CandidateName, CandidateID, VotesReceived, ResultStatus) VALUES (1, 1, 1, 'Ali Hassan', 101, 1500, 'Declared');

INSERT INTO Province_Assembly_Result (PA_ResultID, ProvinceID, ConstituencyID, CandidateName, CandidateID, VotesReceived, ResultStatus) VALUES (2, 1, 2, 'Sana Malik', 104, 2000, 'Declared');

INSERT INTO Province_Assembly_Result (PA_ResultID, ProvinceID, ConstituencyID, CandidateName, CandidateID, VotesReceived, ResultStatus) VALUES (3, 1, 3, 'Ahmed Khan', 103, 1700, 'Declared');

INSERT INTO Province_Assembly_Result (PA_ResultID, ProvinceID, ConstituencyID, CandidateName, CandidateID, VotesReceived, ResultStatus) VALUES (4, 1, 4, 'Nadir Khan', 106, 1800, 'Declared');

INSERT INTO Province_Assembly_Result (PA_ResultID, ProvinceID, ConstituencyID, CandidateName, CandidateID, VotesReceived, ResultStatus) VALUES (5, 1, 5, 'Hamza Ali', 108, 1600, 'Declared');

INSERT INTO Province_Assembly_Result (PA_ResultID, ProvinceID, ConstituencyID, CandidateName, CandidateID, VotesReceived, ResultStatus) VALUES (6, 1, 6, 'Fahad Abbas', 109, 1400, 'Declared');

INSERT INTO Province_Assembly_Result (PA_ResultID, ProvinceID, ConstituencyID, CandidateName, CandidateID, VotesReceived, ResultStatus) VALUES (7, 1, 7, 'Ahmed Malik', 111, 1900, 'Declared');

INSERT INTO Province_Assembly_Result (PA_ResultID, ProvinceID, ConstituencyID, CandidateName, CandidateID, VotesReceived, ResultStatus) VALUES (8, 1, 8, 'Hassan Ali', 112, 1500, 'Declared');

INSERT INTO Province_Assembly_Result (PA_ResultID, ProvinceID, ConstituencyID, CandidateName, CandidateID, VotesReceived, ResultStatus) VALUES (9, 1, 9, 'Kamran Ali', 114, 1300, 'Declared');

INSERT INTO Province_Assembly_Result (PA_ResultID, ProvinceID, ConstituencyID, CandidateName, CandidateID, VotesReceived, ResultStatus) VALUES (10, 1, 10, 'Sadia Ahmed', 115, 1100, 'Declared');

INSERT INTO Province_Assembly_Result (PA_ResultID, ProvinceID, ConstituencyID, CandidateName, CandidateID, VotesReceived, ResultStatus) VALUES (11, 1, 11, 'Fatima Akhtar', 110, 1200, 'Declared');

INSERT INTO Province_Assembly_Result (PA_ResultID, ProvinceID, ConstituencyID, CandidateName, CandidateID, VotesReceived, ResultStatus) VALUES (12, 1, 12, 'Saba Ahmed', 102, 1400, 'Declared');

INSERT INTO Province_Assembly_Result (PA_ResultID, ProvinceID, ConstituencyID, CandidateName, CandidateID, VotesReceived, ResultStatus) VALUES (13, 1, 13, 'Ayesha Raza', 107, 1800, 'Declared');

INSERT INTO Province_Assembly_Result (PA_ResultID, ProvinceID, ConstituencyID, CandidateName, CandidateID, VotesReceived, ResultStatus) VALUES (14, 1, 14, 'Asif Ali', 116, 2000, 'Declared');

INSERT INTO Province_Assembly_Result (PA_ResultID, ProvinceID, ConstituencyID, CandidateName, CandidateID, VotesReceived, ResultStatus) VALUES (15, 1, 15, 'Zainab Riaz', 117, 1700, 'Declared');

INSERT INTO Province_Assembly_Result (PA_ResultID, ProvinceID, ConstituencyID, CandidateName, CandidateID, VotesReceived, ResultStatus) VALUES (16, 1, 16, 'Kashif Raza', 118, 1900, 'Declared');

SELECT CandidateName, CandidateID,ProvinceID,ConstituencyID,VotesReceived 
FROM Province_Assembly_Result 
WHERE VotesReceived = (SELECT MAX(VotesReceived) FROM Province_Assembly_Result);

SELECT CandidateName, CandidateID,ProvinceID,ConstituencyID,VotesReceived 
FROM Province_Assembly_Result 
WHERE VotesReceived = (SELECT MIN(VotesReceived) FROM Province_Assembly_Result);

INSERT INTO National_Assembly_Result (NA_ResultID, TotalPollingStations, VotesReceived, ResultStatus, ConstituencyID, CandidateName, CandidateID) VALUES (1, 100, 12000, 'Declared', 1, 'Ali Hassan', 101);

INSERT INTO National_Assembly_Result (NA_ResultID, TotalPollingStations, VotesReceived, ResultStatus, ConstituencyID, CandidateName, CandidateID) VALUES (2, 120, 15000, 'Declared', 2, 'Sana Malik', 104);

INSERT INTO National_Assembly_Result (NA_ResultID, TotalPollingStations, VotesReceived, ResultStatus, ConstituencyID, CandidateName, CandidateID) VALUES (3, 110, 13000, 'Declared', 3, 'Ahmed Khan', 103);

INSERT INTO National_Assembly_Result (NA_ResultID, TotalPollingStations, VotesReceived, ResultStatus, ConstituencyID, CandidateName, CandidateID) VALUES (4, 115, 14000, 'Declared', 4, 'Nadir Khan', 106);

INSERT INTO National_Assembly_Result (NA_ResultID, TotalPollingStations, VotesReceived, ResultStatus, ConstituencyID, CandidateName, CandidateID) VALUES (5, 105, 12500, 'Declared', 5, 'Hamza Ali', 108);

INSERT INTO National_Assembly_Result (NA_ResultID, TotalPollingStations, VotesReceived, ResultStatus, ConstituencyID, CandidateName, CandidateID) VALUES (6, 130, 16000, 'Declared', 6, 'Fahad Abbas', 109);

INSERT INTO National_Assembly_Result (NA_ResultID, TotalPollingStations, VotesReceived, ResultStatus, ConstituencyID, CandidateName, CandidateID) VALUES (7, 125, 15500, 'Declared', 7, 'Ahmed Malik', 111);

INSERT INTO National_Assembly_Result (NA_ResultID, TotalPollingStations, VotesReceived, ResultStatus, ConstituencyID, CandidateName, CandidateID) VALUES (8, 135, 17000, 'Declared', 8, 'Hassan Ali', 112);

INSERT INTO National_Assembly_Result (NA_ResultID, TotalPollingStations, VotesReceived, ResultStatus, ConstituencyID, CandidateName, CandidateID) VALUES (9, 140, 17500, 'Declared', 9, 'Kamran Ali', 114);

INSERT INTO National_Assembly_Result (NA_ResultID, TotalPollingStations, VotesReceived, ResultStatus, ConstituencyID, CandidateName, CandidateID) VALUES (10, 145, 18000, 'Declared', 10, 'Sadia Ahmed', 115);

INSERT INTO National_Assembly_Result (NA_ResultID, TotalPollingStations, VotesReceived, ResultStatus, ConstituencyID, CandidateName, CandidateID) VALUES (11, 150, 18500, 'Declared', 11, 'Fatima Akhtar', 110);

INSERT INTO National_Assembly_Result (NA_ResultID, TotalPollingStations, VotesReceived, ResultStatus, ConstituencyID, CandidateName, CandidateID) VALUES (12, 160, 19000, 'Declared', 12, 'Saba Ahmed', 102);

INSERT INTO National_Assembly_Result (NA_ResultID, TotalPollingStations, VotesReceived, ResultStatus, ConstituencyID, CandidateName, CandidateID) VALUES (13, 170, 19500, 'Declared', 13, 'Ayesha Raza', 107);

INSERT INTO National_Assembly_Result (NA_ResultID, TotalPollingStations, VotesReceived, ResultStatus, ConstituencyID, CandidateName, CandidateID) VALUES (14, 180, 20000, 'Declared', 14, 'Asif Ali', 116);

INSERT INTO National_Assembly_Result (NA_ResultID, TotalPollingStations, VotesReceived, ResultStatus, ConstituencyID, CandidateName, CandidateID) VALUES (15, 190, 20500, 'Declared', 15, 'Zainab Riaz', 117);

INSERT INTO National_Assembly_Result (NA_ResultID, TotalPollingStations, VotesReceived, ResultStatus, ConstituencyID, CandidateName, CandidateID) VALUES (16, 200, 21000, 'Declared', 16, 'Kashif Raza', 118);

INSERT INTO National_Assembly_Result (NA_ResultID, TotalPollingStations, VotesReceived, ResultStatus, ConstituencyID, CandidateName, CandidateID) VALUES (17, 210, 21500, 'Declared', 17, 'Farah Khan', 119);

SELECT CandidateName, CandidateID, ConstituencyID,VotesReceived 
FROM National_Assembly_Result 
WHERE VotesReceived = ( 
    SELECT MAX(VotesReceived) 
    FROM National_Assembly_Result 
);

SELECT CandidateName, CandidateID, ConstituencyID,VotesReceived 
FROM National_Assembly_Result 
WHERE VotesReceived = ( 
    SELECT MIN(VotesReceived) 
    FROM National_Assembly_Result 
);

SELECT * FROM CANDIDATE;

INSERT INTO Elected_Official (ElectedOfficialID, PartyID, ConstituencyID, VotesReceived, ElectedOfficialName, TermStart, TermEnd) 
VALUES (1, 1, 1, 12000, 'Ali Hassan', TO_DATE('01-JUL-2024', 'DD-MON-YYYY'), TO_DATE('01-JUL-2029', 'DD-MON-YYYY'));

INSERT INTO Elected_Official (ElectedOfficialID, PartyID, ConstituencyID, VotesReceived, ElectedOfficialName, TermStart, TermEnd) 
VALUES (2, 3, 3, 13000, 'Ahmed Khan', TO_DATE('01-JUL-2024', 'DD-MON-YYYY'), TO_DATE('01-JUL-2029', 'DD-MON-YYYY'));

INSERT INTO Elected_Official (ElectedOfficialID, PartyID, ConstituencyID, VotesReceived, ElectedOfficialName, TermStart, TermEnd) 
VALUES (3, 4, 2, 15000, 'Sana Malik', TO_DATE('01-JUL-2024', 'DD-MON-YYYY'), TO_DATE('01-JUL-2029', 'DD-MON-YYYY'));

INSERT INTO Elected_Official (ElectedOfficialID, PartyID, ConstituencyID, VotesReceived, ElectedOfficialName, TermStart, TermEnd) 
VALUES (4, 6, 4, 14000, 'Nadir Khan', TO_DATE('01-JUL-2024', 'DD-MON-YYYY'), TO_DATE('01-JUL-2029', 'DD-MON-YYYY'));

INSERT INTO Elected_Official (ElectedOfficialID, PartyID, ConstituencyID, VotesReceived, ElectedOfficialName, TermStart, TermEnd) 
VALUES (5, 8, 5, 12500, 'Hamza Ali', TO_DATE('01-JUL-2024', 'DD-MON-YYYY'), TO_DATE('01-JUL-2029', 'DD-MON-YYYY'));

INSERT INTO Elected_Official (ElectedOfficialID, PartyID, ConstituencyID, VotesReceived, ElectedOfficialName, TermStart, TermEnd) 
VALUES (6, 9, 6, 16000, 'Fahad Abbas', TO_DATE('01-JUL-2024', 'DD-MON-YYYY'), TO_DATE('01-JUL-2029', 'DD-MON-YYYY'));

INSERT INTO Elected_Official (ElectedOfficialID, PartyID, ConstituencyID, VotesReceived, ElectedOfficialName, TermStart, TermEnd) 
VALUES (7, 11, 7, 15500, 'Ahmed Malik', TO_DATE('01-JUL-2024', 'DD-MON-YYYY'), TO_DATE('01-JUL-2029', 'DD-MON-YYYY'));

INSERT INTO Elected_Official (ElectedOfficialID, PartyID, ConstituencyID, VotesReceived, ElectedOfficialName, TermStart, TermEnd) 
VALUES (8, 12, 8, 17000, 'Hassan Ali', TO_DATE('01-JUL-2024', 'DD-MON-YYYY'), TO_DATE('01-JUL-2029', 'DD-MON-YYYY'));

INSERT INTO Elected_Official (ElectedOfficialID, PartyID, ConstituencyID, VotesReceived, ElectedOfficialName, TermStart, TermEnd) 
VALUES (9, 14, 9, 17500, 'Kamran Ali', TO_DATE('01-JUL-2024', 'DD-MON-YYYY'), TO_DATE('01-JUL-2029', 'DD-MON-YYYY'));

INSERT INTO Elected_Official (ElectedOfficialID, PartyID, ConstituencyID, VotesReceived, ElectedOfficialName, TermStart, TermEnd) 
VALUES (10, 15, 10, 18000, 'Sadia Ahmed', TO_DATE('01-JUL-2024', 'DD-MON-YYYY'), TO_DATE('01-JUL-2029', 'DD-MON-YYYY'));

INSERT INTO Elected_Official (ElectedOfficialID, PartyID, ConstituencyID, VotesReceived, ElectedOfficialName, TermStart, TermEnd) 
VALUES (11, 10, 11, 18500, 'Fatima Akhtar', TO_DATE('01-JUL-2024', 'DD-MON-YYYY'), TO_DATE('01-JUL-2029', 'DD-MON-YYYY'));

INSERT INTO Elected_Official (ElectedOfficialID, PartyID, ConstituencyID, VotesReceived, ElectedOfficialName, TermStart, TermEnd) 
VALUES (12, 2, 12, 19000, 'Saba Ahmed', TO_DATE('01-JUL-2024', 'DD-MON-YYYY'), TO_DATE('01-JUL-2029', 'DD-MON-YYYY'));

INSERT INTO Elected_Official (ElectedOfficialID, PartyID, ConstituencyID, VotesReceived, ElectedOfficialName, TermStart, TermEnd) 
VALUES (13, 7, 13, 19500, 'Ayesha Raza', TO_DATE('01-JUL-2024', 'DD-MON-YYYY'), TO_DATE('01-JUL-2029', 'DD-MON-YYYY'));

INSERT INTO Elected_Official (ElectedOfficialID, PartyID, ConstituencyID, VotesReceived, ElectedOfficialName, TermStart, TermEnd) 
VALUES (14, 1, 14, 20000, 'Asif Ali', TO_DATE('01-JUL-2024', 'DD-MON-YYYY'), TO_DATE('01-JUL-2029', 'DD-MON-YYYY'));

INSERT INTO Elected_Official (ElectedOfficialID, PartyID, ConstituencyID, VotesReceived, ElectedOfficialName, TermStart, TermEnd) 
VALUES (15, 2, 15, 20500, 'Zainab Riaz', TO_DATE('01-JUL-2024', 'DD-MON-YYYY'), TO_DATE('01-JUL-2029', 'DD-MON-YYYY'));

SELECT * FROM Family_Member_Record;

SELECT * FROM Family;

SELECT f.FAMILYID, f.FAMILY_MEMBER_NAME, m.MEMBERID, m.GENDER, m.CNIC, m.DATEOFBIRTH, m.VOTER_ID 
FROM family_member_record m 
JOIN family f ON m.FAMILY_ID = f.FAMILYID;

SELECT * FROM Voter;

SELECT v.VOTERID, v.CITY, v.GENDER AS VoterGender, v.STATE, v.EMAIL, v.NAME AS VoterName, v.CNIC AS VoterCNIC, v.DATEOFBIRTH AS VoterDateOfBirth, 
       fmr.MEMBERID, fmr.GENDER AS MemberGender, fmr.CNIC AS MemberCNIC, fmr.DATEOFBIRTH AS MemberDateOfBirth, fmr.FAMILY_ID 
FROM voter v 
INNER JOIN family_member_record fmr ON v.VOTERID = fmr.VOTER_ID;

SELECT * FROM Vote;

SELECT * FROM Voter;

SELECT v.VOTERID, v.CITY, v.GENDER AS VoterGender, v.STATE, v.EMAIL, v.NAME AS VoterName, v.CNIC AS VoterCNIC, v.DATEOFBIRTH AS VoterDateOfBirth, 
       fmr.MEMBERID, fmr.GENDER AS MemberGender, fmr.CNIC AS MemberCNIC, fmr.DATEOFBIRTH AS MemberDateOfBirth, fmr.FAMILY_ID, fmr.VOTER_ID, 
       vt.VOTEID, vt.CONSTITUENCYID, vt.POLLINGSTATIONID, vt.ELECTIONID, vt.CANDIDATEID, vt.VERIFIED, vt.VOTETYPE, vt.VOTEDATETIME 
FROM voter v 
INNER JOIN family_member_record fmr ON v.VOTERID = fmr.VOTER_ID 
INNER JOIN vote vt ON v.VOTERID = vt.VOTERID;

select * from elected_official;

select * from vote;

select * from national_assembly_result;

truncate table province_assembly_result


select * from polling_station_result;

CREATE SEQUENCE pa_result_seq 
START WITH 1 
INCREMENT BY 1;

INSERT INTO Province_Assembly_Result (PA_ResultID, ProvinceID, ConstituencyID, CandidateName, CandidateID, VotesReceived, ResultStatus) 
SELECT pa_result_seq.NEXTVAL, 
       CASE  
           WHEN ConstituencyID BETWEEN 1 AND 5 THEN 1 
           WHEN ConstituencyID BETWEEN 6 AND 10 THEN 2 
           WHEN ConstituencyID = 11 THEN 3 
           WHEN ConstituencyID BETWEEN 12 AND 16 THEN 4 
           WHEN ConstituencyID = 17 THEN 5 
           ELSE NULL  -- Handle any other cases if needed 
       END AS ProvinceID, 
       ConstituencyID, 
       CandidateName, 
       CandidateID, 
       VotesReceived, 
       'Declared' AS ResultStatus 
FROM Polling_Station_Result 
WHERE ConstituencyID BETWEEN 1 AND 17;

select * from polling_station_result;

select * from province_assembly_result;

select * from vote where candidateid=114;

select * from polling_station_result;

select * from polling_station_result where candidatename='Rizwan Ahmed';

DELETE FROM Polling_Station_Result 
WHERE POLLINGSTATIONRESULTID IN ( 
    SELECT POLLINGSTATIONRESULTID 
    FROM ( 
        SELECT  
            POLLINGSTATIONRESULTID, 
            ROW_NUMBER() OVER (PARTITION BY CONSTITUENCYID, CANDIDATEID, ELECTIONID ORDER BY POLLINGSTATIONRESULTID) AS RN 
        FROM Polling_Station_Result 
    ) 
    WHERE RN > 1 
);

select * from polling_station_result;

select * from polling_station_result where candidatename='Rizwan Ahmed';

truncate table province_assembly_result


INSERT INTO Province_Assembly_Result (PA_ResultID, ProvinceID, ConstituencyID, CandidateName, CandidateID, VotesReceived, ResultStatus) 
SELECT pa_result_seq.NEXTVAL, 
       CASE  
           WHEN ConstituencyID BETWEEN 1 AND 5 THEN 1 
           WHEN ConstituencyID BETWEEN 6 AND 10 THEN 2 
           WHEN ConstituencyID = 11 THEN 3 
           WHEN ConstituencyID BETWEEN 12 AND 16 THEN 4 
           WHEN ConstituencyID = 17 THEN 5 
           ELSE NULL  -- Handle any other cases if needed 
       END AS ProvinceID, 
       ConstituencyID, 
       CandidateName, 
       CandidateID, 
       VotesReceived, 
       'Declared' AS ResultStatus 
FROM Polling_Station_Result 
WHERE ConstituencyID BETWEEN 1 AND 17;

INSERT INTO Province_Assembly_Result (PA_ResultID, ProvinceID, ConstituencyID, CandidateName, CandidateID, VotesReceived, ResultStatus) 
SELECT pa_result_seq.NEXTVAL, 
       CASE  
           WHEN ConstituencyID BETWEEN 1 AND 5 THEN 1 
           WHEN ConstituencyID BETWEEN 6 AND 10 THEN 2 
           WHEN ConstituencyID = 11 THEN 3 
           WHEN ConstituencyID BETWEEN 12 AND 16 THEN 4 
           WHEN ConstituencyID = 17 THEN 5 
           ELSE NULL  -- Handle any other cases if needed 
       END AS ProvinceID, 
       ConstituencyID, 
       CandidateName, 
       CandidateID, 
       VotesReceived, 
       'Declared' AS ResultStatus 
FROM Polling_Station_Result 
WHERE ConstituencyID BETWEEN 1 AND 17;

select * from province_assembly_result;

select * from polling_station_result;

select * from polling_station_result where candidatename='Rizwan Ahmed';

SELECT pa_result_seq.NEXTVAL 
FROM dual;

SELECT pa_result_seq.NEXTVAL 
FROM dual;

SELECT pa_result_seq.NEXTVAL 
FROM dual;

SELECT pa_result_seq.NEXTVAL 
FROM dual;

SELECT pa_result_seq.NEXTVAL FROM dual;

SELECT pa_result_seq.NEXTVAL FROM dual;

SELECT pa_result_seq.NEXTVAL FROM dual;

ALTER SEQUENCE pa_result_seq 
INCREMENT BY 1;

SELECT pa_result_seq.NEXTVAL FROM dual;

select * from province_assembly_result;

select * from province_assembly_result where pa_resultid=1;

select * from province_assembly_result;

DELETE FROM Province_Assembly_Result 
WHERE PA_RESULTID IN ( 
    SELECT PA_RESULTID 
    FROM ( 
        SELECT  
           PA_RESULTID, 
            ROW_NUMBER() OVER (PARTITION BY PROVINCEID, CONSTITUENCYID, CANDIDATEID ORDER BY PA_RESULTID) AS RN 
        FROM Province_Assembly_Result 
    ) 
    WHERE RN > 1 
);

select * from province_assembly_result;

select * from province_assembly_result where candidatename='Kamran Ali';

truncate table national_assembly_result


CREATE SEQUENCE na_result_seq 
START WITH 1 
INCREMENT BY 1;

select * from polling_station_result;

    select * from national_assembly_result;

BEGIN 
    FOR rec IN ( 
        SELECT COUNT(DISTINCT psr.PollingStationResultID) AS TotalPollingStations, 
               SUM(psr.VotesReceived) AS VotesReceived, 
               'Declared' AS ResultStatus, 
               psr.ConstituencyID, 
               psr.CandidateName, 
               psr.CandidateID 
        FROM Polling_Station_Result psr 
        WHERE psr.ConstituencyID BETWEEN 1 AND 17 
        AND NOT EXISTS ( 
            SELECT 1 
            FROM National_Assembly_Result nar 
            WHERE nar.CandidateID = psr.CandidateID 
              AND nar.ConstituencyID = psr.ConstituencyID 
        ) 
        GROUP BY psr.ConstituencyID, psr.CandidateName, psr.CandidateID 
        ORDER BY psr.CandidateID ASC  -- Order by CandidateID ascending 
    ) LOOP 
        INSERT INTO National_Assembly_Result (NA_ResultID, TotalPollingStations, VotesReceived, ResultStatus, ConstituencyID, CandidateName, CandidateID) 
        VALUES (na_result_seq.NEXTVAL, rec.TotalPollingStations, rec.VotesReceived, rec.ResultStatus, rec.ConstituencyID, rec.CandidateName, rec.CandidateID); 
    END LOOP; 
END;
/

select * from national_assembly_result;

truncate table national_assembly_result


BEGIN 
    FOR rec IN ( 
        SELECT COUNT(DISTINCT psr.PollingStationResultID) AS TotalPollingStations, 
               SUM(psr.VotesReceived) AS VotesReceived, 
               'Declared' AS ResultStatus, 
               psr.ConstituencyID, 
               psr.CandidateName, 
               psr.CandidateID 
        FROM Polling_Station_Result psr 
        WHERE psr.ConstituencyID BETWEEN 18 AND 34 
        AND NOT EXISTS ( 
            SELECT 1 
            FROM National_Assembly_Result nar 
            WHERE nar.CandidateID = psr.CandidateID 
              AND nar.ConstituencyID = psr.ConstituencyID 
        ) 
        GROUP BY psr.ConstituencyID, psr.CandidateName, psr.CandidateID 
        ORDER BY psr.CandidateID ASC  -- Order by CandidateID ascending 
    ) LOOP 
        INSERT INTO National_Assembly_Result (NA_ResultID, TotalPollingStations, VotesReceived, ResultStatus, ConstituencyID, CandidateName, CandidateID) 
        VALUES (na_result_seq.NEXTVAL, rec.TotalPollingStations, rec.VotesReceived, rec.ResultStatus, rec.ConstituencyID, rec.CandidateName, rec.CandidateID); 
    END LOOP; 
END; 

/

select * from national_assembly_result;

select * from national_assembly_result where candidatename='rizwan ahmed';

select * from national_assembly_result where candidatename='Rizwan Ahmed';

CREATE SEQUENCE elected_official_seq 
START WITH 1 
INCREMENT BY 1;

INSERT INTO Elected_Official (ElectedOfficialID, PartyID, ConstituencyID, VotesReceived, ElectedOfficialName, TermStart, TermEnd) 
SELECT elected_official_seq.NEXTVAL, 
       c.Party_ID, 
       nar.ConstituencyID, 
       nar.VotesReceived, 
       nar.CandidateName, 
       TO_DATE('01-JUL-2024', 'DD-MON-YYYY'),  -- TermStart set to 01-JUL-2024 
       TO_DATE('01-JUL-2029', 'DD-MON-YYYY')  -- TermEnd set to 01-JUL-2029 
FROM national_assembly_result nar 
JOIN Candidate c ON nar.CandidateID = c.candidate_ID 
WHERE (nar.ConstituencyID, nar.VotesReceived) IN ( 
    SELECT ConstituencyID, MAX(VotesReceived) 
    FROM national_assembly_result 
    GROUP BY ConstituencyID 
);

select * from elected_officiAL;

INSERT INTO Elected_Official (ElectedOfficialID, PartyID, ConstituencyID, VotesReceived, ElectedOfficialName, TermStart, TermEnd) 
SELECT elected_official_seq.NEXTVAL, 
       c.Party_ID, 
       par.ConstituencyID, 
       par.VotesReceived, 
       par.CandidateName, 
       TO_DATE('01-JUL-2024', 'DD-MON-YYYY'),  -- TermStart set to 01-JUL-2024 
       NULL                                    -- TermEnd is unknown at this time 
FROM province_assembly_result par 
JOIN Candidate c ON par.CandidateID = c.candidate_ID 
WHERE (par.ConstituencyID, par.VotesReceived) IN ( 
    SELECT ConstituencyID, MAX(VotesReceived) 
    FROM province_assembly_result 
    GROUP BY ConstituencyID 
);

INSERT INTO Elected_Official (ElectedOfficialID, PartyID, ConstituencyID, VotesReceived, ElectedOfficialName, TermStart, TermEnd) 
SELECT elected_official_seq.NEXTVAL, 
       c.Party_ID, 
       nar.ConstituencyID, 
       nar.VotesReceived, 
       nar.CandidateName, 
       TO_DATE('01-JUL-2024', 'DD-MON-YYYY'),  -- TermStart set to 01-JUL-2024 
       TO_DATE('01-JUL-2029', 'DD-MON-YYYY')  -- TermEnd set to 01-JUL-2029 
FROM national_assembly_result nar 
JOIN Candidate c ON nar.CandidateID = c.candidate_ID 
WHERE (nar.ConstituencyID, nar.VotesReceived) IN ( 
    SELECT ConstituencyID, MAX(VotesReceived) 
    FROM national_assembly_result 
    GROUP BY ConstituencyID 
);

TRUNCATE TABLE ELECTED_OFFICIAL


select * from elected_officiAL;

UPDATE Elected_Official eo 
SET eo.TermEnd = TO_DATE('01-JUL-2024', 'DD-MON-YYYY')  -- Update TermEnd to 01-JUL-2024 
WHERE eo.ConstituencyID IN ( 
    SELECT par.ConstituencyID 
    FROM province_assembly_result par 
    JOIN Candidate c ON par.CandidateID = c.Candidate_ID 
    WHERE (par.ConstituencyID, par.VotesReceived) IN ( 
        SELECT ConstituencyID, MAX(VotesReceived) 
        FROM province_assembly_result 
        GROUP BY ConstituencyID 
    ) 
);

select * from elected_officiAL;

UPDATE Elected_Official eo 
SET eo.TermEnd = TO_DATE('01-JUL-2029', 'DD-MON-YYYY')  -- Update TermEnd to 01-JUL-2024 
WHERE eo.ConstituencyID IN ( 
    SELECT par.ConstituencyID 
    FROM province_assembly_result par 
    JOIN Candidate c ON par.CandidateID = c.Candidate_ID 
    WHERE (par.ConstituencyID, par.VotesReceived) IN ( 
        SELECT ConstituencyID, MAX(VotesReceived) 
        FROM province_assembly_result 
        GROUP BY ConstituencyID 
    ) 
);

select * from elected_officiAL;

CREATE USER voter IDENTIFIED BY password_voter;

CREATE USER polling_officer IDENTIFIED BY password_polling_officer;

CONNECT sys as sysdba


CONNECT zenebb.19@gmail.com AS SYSDBA


select * from polling_station_result;

select * from elected_official;

select * from elected_official;

INSERT INTO Elected_Official (ElectedOfficialID, PartyID, ConstituencyID, VotesReceived, ElectedOfficialName, TermStart, TermEnd)  
SELECT elected_official_seq.NEXTVAL,  
       c.Party_ID,  
       par.ConstituencyID,  
       par.VotesReceived,  
       par.CandidateName,  
       TO_DATE('01-JUL-2024', 'DD-MON-YYYY'),  -- TermStart set to 01-JUL-2024  
       NULL                                    -- TermEnd is unknown at this time  
FROM province_assembly_result par  
JOIN Candidate c ON par.CandidateID = c.candidate_ID  
WHERE (par.ConstituencyID, par.VotesReceived) IN (  
    SELECT ConstituencyID, MAX(VotesReceived)  
    FROM province_assembly_result  
    GROUP BY ConstituencyID  
);

INSERT INTO Elected_Official (ElectedOfficialID, PartyID, ConstituencyID, VotesReceived, ElectedOfficialName, TermStart, TermEnd) 
SELECT elected_official_seq.NEXTVAL, 
       c.Party_ID, 
       nar.ConstituencyID, 
       nar.VotesReceived, 
       nar.CandidateName, 
       TO_DATE('01-JUL-2024', 'DD-MON-YYYY'),  -- TermStart set to 01-JUL-2024 
       TO_DATE('01-JUL-2029', 'DD-MON-YYYY')  -- TermEnd set to 01-JUL-2029 
FROM national_assembly_result nar 
JOIN Candidate c ON nar.CandidateID = c.candidate_ID 
WHERE (nar.ConstituencyID, nar.VotesReceived) IN ( 
    SELECT ConstituencyID, MAX(VotesReceived) 
    FROM national_assembly_result 
    GROUP BY ConstituencyID 
);

select * from elected_officiAL;

INSERT INTO Elected_Official (ElectedOfficialID, PartyID, ConstituencyID, VotesReceived, ElectedOfficialName, TermStart, TermEnd) 
SELECT elected_official_seq.NEXTVAL, 
       c.Party_ID, 
       nar.ConstituencyID, 
       nar.VotesReceived, 
       nar.CandidateName, 
       TO_DATE('01-JUL-2024', 'DD-MON-YYYY'),  -- TermStart set to 01-JUL-2024 
       TO_DATE('01-JUL-2029', 'DD-MON-YYYY')  -- TermEnd set to 01-JUL-2029 
FROM national_assembly_result nar 
JOIN Candidate c ON nar.CandidateID = c.candidate_ID 
WHERE (nar.ConstituencyID, nar.VotesReceived) IN ( 
    SELECT ConstituencyID, MAX(VotesReceived) 
    FROM national_assembly_result 
    GROUP BY ConstituencyID 
);

UPDATE Elected_Official eo 
SET eo.TermEnd = TO_DATE('01-JUL-2029', 'DD-MON-YYYY')  -- Update TermEnd to 01-JUL-2024 
WHERE eo.ConstituencyID IN ( 
    SELECT par.ConstituencyID 
    FROM province_assembly_result par 
    JOIN Candidate c ON par.CandidateID = c.Candidate_ID 
    WHERE (par.ConstituencyID, par.VotesReceived) IN ( 
        SELECT ConstituencyID, MAX(VotesReceived) 
        FROM province_assembly_result 
        GROUP BY ConstituencyID 
    ) 
);

select * from elected_officiAL;

select * from elected_officiAL;

select * from elected_officiAL order by constituencyid;

DELETE FROM ELECTED_OFFICIAL 
WHERE (CONSTITUENCYID, PARTYID, ELECTEDOFFICIALNAME) IN ( 
    SELECT CONSTITUENCYID, PARTYID, ELECTEDOFFICIALNAME 
    FROM ( 
        SELECT  
            CONSTITUENCYID, 
            PARTYID, 
            ELECTEDOFFICIALNAME, 
            ROW_NUMBER() OVER (PARTITION BY CONSTITUENCYID, PARTYID, ELECTEDOFFICIALNAME ORDER BY ELECTEDOFFICIALID) AS rn 
        FROM ELECTED_OFFICIAL 
    )  
    WHERE rn > 1 
);

select * from elected_officiAL order by constituencyid;

select * from national_assembly_result;

truncate table elected_official


INSERT INTO Elected_Official (ElectedOfficialID, PartyID, ConstituencyID, VotesReceived, ElectedOfficialName, TermStart, TermEnd)  
SELECT elected_official_seq.NEXTVAL,  
       c.Party_ID,  
       par.ConstituencyID,  
       par.VotesReceived,  
       par.CandidateName,  
       TO_DATE('01-JUL-2024', 'DD-MON-YYYY'),  -- TermStart set to 01-JUL-2024  
       TO_DATE('30-JUN-2029', 'DD-MON-YYYY')                                    -- TermEnd is unknown at this time  
FROM province_assembly_result par  
JOIN Candidate c ON par.CandidateID = c.candidate_ID  
WHERE (par.ConstituencyID, par.VotesReceived) IN (  
    SELECT ConstituencyID, MAX(VotesReceived)  
    FROM province_assembly_result  
    GROUP BY ConstituencyID  
);

INSERT INTO Elected_Official (ElectedOfficialID, PartyID, ConstituencyID, VotesReceived, ElectedOfficialName, TermStart, TermEnd) 
SELECT elected_official_seq.NEXTVAL, 
       c.Party_ID, 
       nar.ConstituencyID, 
       nar.VotesReceived, 
       nar.CandidateName, 
       TO_DATE('01-JUL-2024', 'DD-MON-YYYY'),  -- TermStart set to 01-JUL-2024 
       TO_DATE('30-JUN-2029', 'DD-MON-YYYY')  -- TermEnd set to 01-JUL-2029 
FROM national_assembly_result nar 
JOIN Candidate c ON nar.CandidateID = c.candidate_ID 
WHERE (nar.ConstituencyID, nar.VotesReceived) IN ( 
    SELECT ConstituencyID, MAX(VotesReceived) 
    FROM national_assembly_result 
    GROUP BY ConstituencyID 
);

select * from elected_officiAL order by constituencyid;

select * from elected_officiAL order by constituencyid;

UPDATE ELECTED_OFFICIAL eo 
SET eo.TERMSTART = ( 
    SELECT  
        CASE 
            WHEN tie_size = 2 AND rank_in_tie = 1 THEN DATE '2024-07-01'  -- First official in tie starts on July 1, 2024 
            WHEN tie_size = 2 AND rank_in_tie = 2 THEN DATE '2027-01-01'  -- Second official in tie starts on January 1, 2027 
            WHEN tie_size = 3 AND rank_in_tie = 1 THEN DATE '2024-07-01'  -- First slot starts on July 1, 2024 
            WHEN tie_size = 3 AND rank_in_tie = 2 THEN DATE '2026-01-01'  -- Second slot starts on January 1, 2026 
            WHEN tie_size = 3 AND rank_in_tie = 3 THEN DATE '2027-07-01'  -- Third slot starts on July 1, 2027 
        END AS TERMSTART 
    FROM ( 
        SELECT  
            eo_inner.ElectedOfficialID, 
            eo_inner.ConstituencyID, 
            eo_inner.VotesReceived, 
            COUNT(*) OVER (PARTITION BY eo_inner.ConstituencyID) AS tie_size, 
            ROW_NUMBER() OVER (PARTITION BY eo_inner.ConstituencyID ORDER BY eo_inner.ElectedOfficialID) AS rank_in_tie 
        FROM ELECTED_OFFICIAL eo_inner 
        WHERE eo_inner.ConstituencyID = eo.ConstituencyID 
        ORDER BY eo_inner.ElectedOfficialID 
    ) tie 
    WHERE tie.ElectedOfficialID = eo.ElectedOfficialID 
    AND tie.ConstituencyID = eo.ConstituencyID 
    AND tie.VotesReceived = eo.VotesReceived 
    AND tie.rank_in_tie = 1  -- Only update for the first official in the tie 
), 
eo.TERMEND = ( 
    SELECT  
        CASE 
            WHEN tie_size = 2 AND rank_in_tie = 1 THEN DATE '2026-06-30'  -- First official in tie ends on June 30, 2026 
            WHEN tie_size = 2 AND rank_in_tie = 2 THEN DATE '2029-06-30'  -- Second official in tie ends on June 30, 2029 
            WHEN tie_size = 3 AND rank_in_tie = 1 THEN DATE '2026-06-30'  -- First slot ends on June 30, 2026 
            WHEN tie_size = 3 AND rank_in_tie = 2 THEN DATE '2027-12-31'  -- Second slot ends on December 31, 2027 
            WHEN tie_size = 3 AND rank_in_tie = 3 THEN DATE '2029-06-30'  -- Third slot ends on June 30, 2029 
        END AS TERMEND 
    FROM ( 
        SELECT  
            eo_inner.ElectedOfficialID, 
            eo_inner.ConstituencyID, 
            eo_inner.VotesReceived, 
            COUNT(*) OVER (PARTITION BY eo_inner.ConstituencyID) AS tie_size, 
            ROW_NUMBER() OVER (PARTITION BY eo_inner.ConstituencyID ORDER BY eo_inner.ElectedOfficialID) AS rank_in_tie 
        FROM ELECTED_OFFICIAL eo_inner 
        WHERE eo_inner.ConstituencyID = eo.ConstituencyID 
        ORDER BY eo_inner.ElectedOfficialID 
    ) tie 
    WHERE tie.ElectedOfficialID = eo.ElectedOfficialID 
    AND tie.ConstituencyID = eo.ConstituencyID 
    AND tie.VotesReceived = eo.VotesReceived 
    AND tie.rank_in_tie = 1  -- Only update for the first official in the tie 
) 
WHERE EXISTS ( 
    SELECT 1 
    FROM ( 
        SELECT  
            ConstituencyID, 
            MAX(VotesReceived) AS max_votes 
        FROM ELECTED_OFFICIAL 
        GROUP BY ConstituencyID 
    ) t 
    WHERE eo.ConstituencyID = t.ConstituencyID 
    AND eo.VotesReceived = t.max_votes 
    HAVING COUNT(*) > 1  -- Only update if there's a tie (more than one official with max votes in a constituency) 
);

UPDATE ELECTED_OFFICIAL eo 
SET eo.TERMSTART = ( 
    SELECT  
        CASE 
            WHEN tie.tie_size = 2 AND tie.rank_in_tie = 1 THEN DATE '2024-07-01'  -- First official in tie starts on July 1, 2024 
            WHEN tie.tie_size = 2 AND tie.rank_in_tie = 2 THEN DATE '2027-01-01'  -- Second official in tie starts on January 1, 2027 
            WHEN tie.tie_size = 3 AND tie.rank_in_tie = 1 THEN DATE '2024-07-01'  -- First slot starts on July 1, 2024 
            WHEN tie.tie_size = 3 AND tie.rank_in_tie = 2 THEN DATE '2026-01-01'  -- Second slot starts on January 1, 2026 
            WHEN tie.tie_size = 3 AND tie.rank_in_tie = 3 THEN DATE '2027-07-01'  -- Third slot starts on July 1, 2027 
        END AS TERMSTART 
    FROM ( 
        SELECT  
            eo_inner.ElectedOfficialID, 
            eo_inner.ConstituencyID, 
            eo_inner.VotesReceived, 
            COUNT(*) OVER (PARTITION BY eo_inner.ConstituencyID) AS tie_size, 
            ROW_NUMBER() OVER (PARTITION BY eo_inner.ConstituencyID ORDER BY eo_inner.ElectedOfficialID) AS rank_in_tie 
        FROM ELECTED_OFFICIAL eo_inner 
        WHERE eo_inner.ConstituencyID = eo.ConstituencyID 
        AND eo_inner.VotesReceived = eo.VotesReceived 
    ) tie 
    WHERE tie.ElectedOfficialID = eo.ElectedOfficialID 
    AND tie.ConstituencyID = eo.ConstituencyID 
    AND tie.rank_in_tie = 1  -- Only update for the first official in the tie 
), 
eo.TERMEND = ( 
    SELECT  
        CASE 
            WHEN tie.tie_size = 2 AND tie.rank_in_tie = 1 THEN DATE '2026-06-30'  -- First official in tie ends on June 30, 2026 
            WHEN tie.tie_size = 2 AND tie.rank_in_tie = 2 THEN DATE '2029-06-30'  -- Second official in tie ends on June 30, 2029 
            WHEN tie.tie_size = 3 AND tie.rank_in_tie = 1 THEN DATE '2026-06-30'  -- First slot ends on June 30, 2026 
            WHEN tie.tie_size = 3 AND tie.rank_in_tie = 2 THEN DATE '2027-12-31'  -- Second slot ends on December 31, 2027 
            WHEN tie.tie_size = 3 AND tie.rank_in_tie = 3 THEN DATE '2029-06-30'  -- Third slot ends on June 30, 2029 
        END AS TERMEND 
    FROM ( 
        SELECT  
            eo_inner.ElectedOfficialID, 
            eo_inner.ConstituencyID, 
            eo_inner.VotesReceived, 
            COUNT(*) OVER (PARTITION BY eo_inner.ConstituencyID) AS tie_size, 
            ROW_NUMBER() OVER (PARTITION BY eo_inner.ConstituencyID ORDER BY eo_inner.ElectedOfficialID) AS rank_in_tie 
        FROM ELECTED_OFFICIAL eo_inner 
        WHERE eo_inner.ConstituencyID = eo.ConstituencyID 
        AND eo_inner.VotesReceived = eo.VotesReceived 
    ) tie 
    WHERE tie.ElectedOfficialID = eo.ElectedOfficialID 
    AND tie.ConstituencyID = eo.ConstituencyID 
    AND tie.rank_in_tie = 1  -- Only update for the first official in the tie 
) 
WHERE EXISTS ( 
    SELECT 1 
    FROM ( 
        SELECT  
            ConstituencyID, 
            MAX(VotesReceived) AS max_votes 
        FROM ELECTED_OFFICIAL 
        GROUP BY ConstituencyID 
    ) t 
    WHERE eo.ConstituencyID = t.ConstituencyID 
    AND eo.VotesReceived = t.max_votes 
    HAVING COUNT(*) > 1  -- Only update if there's a tie (more than one official with max votes in a constituency) 
);

select * from elected_officiAL order by constituencyid;

UPDATE Elected_Official 
SET TermStart = TO_DATE('01-JUL-2024', 'DD-MON-YYYY'), 
    TermEnd = ADD_MONTHS(TO_DATE('01-JUL-2024', 'DD-MON-YYYY'), 30)  -- 30 months (2.5 years) from TermStart 
WHERE ElectedOfficialID IN ( 
    SELECT e.ElectedOfficialID 
    FROM Elected_Official e 
    JOIN ( 
        SELECT ConstituencyID, MAX(VotesReceived) AS MaxVotes 
        FROM ( 
            SELECT par.ConstituencyID, par.VotesReceived 
            FROM province_assembly_result par 
            UNION ALL 
            SELECT nar.ConstituencyID, nar.VotesReceived 
            FROM national_assembly_result nar 
        ) combined_results 
        GROUP BY ConstituencyID 
        HAVING COUNT(*) = 2  -- Two candidates with the same max votes in the constituency 
    ) sub ON e.ConstituencyID = sub.ConstituencyID AND e.VotesReceived = sub.MaxVotes 
);

select * from elected_officiAL order by constituencyid;

WITH UpdatedOfficials AS ( 
    -- Update initial TermStart and TermEnd for Type 1 tie (2.5 years) 
    UPDATE Elected_Official e1 
    SET TermStart = TO_DATE('01-JUL-2024', 'DD-MON-YYYY'), 
        TermEnd = ADD_MONTHS(TO_DATE('01-JUL-2024', 'DD-MON-YYYY'), 30)  -- 30 months (2.5 years) from TermStart 
    WHERE ElectedOfficialID IN ( 
        SELECT e.ElectedOfficialID 
        FROM Elected_Official e 
        JOIN ( 
            SELECT ConstituencyID, MAX(VotesReceived) AS MaxVotes 
            FROM ( 
                SELECT par.ConstituencyID, par.VotesReceived 
                FROM province_assembly_result par 
                UNION ALL 
                SELECT nar.ConstituencyID, nar.VotesReceived 
                FROM national_assembly_result nar 
            ) combined_results 
            GROUP BY ConstituencyID 
            HAVING COUNT(*) = 2  -- Two candidates with the same max votes in the constituency 
        ) sub ON e.ConstituencyID = sub.ConstituencyID AND e.VotesReceived = sub.MaxVotes 
        RETURNING e1.ConstituencyID, e1.TermEnd 
    ) 
), NextTermUpdate AS ( 
    -- Select ConstituencyID and TermEnd for sequential update 
    SELECT eo.ConstituencyID, eo.TermEnd 
    FROM Elected_Official eo 
    JOIN UpdatedOfficials uo ON eo.ConstituencyID = uo.ConstituencyID 
) 
-- Update TermStart for the next candidate to be one day after the previous TermEnd 
UPDATE Elected_Official e2 
SET TermStart = (SELECT TermEnd + 1 FROM NextTermUpdate WHERE ConstituencyID = e2.ConstituencyID), 
    TermEnd = (SELECT TermEnd + 1 + ADD_MONTHS(TO_DATE('01-JUL-2024', 'DD-MON-YYYY'), 30) - TO_DATE('01-JUL-2024', 'DD-MON-YYYY') FROM NextTermUpdate WHERE ConstituencyID = e2.ConstituencyID) 
WHERE EXISTS ( 
    SELECT 1 
    FROM NextTermUpdate 
    WHERE ConstituencyID = e2.ConstituencyID 
)


COMMIT;

UPDATE Elected_Official e1 
SET TermStart = TO_DATE('01-JUL-2024', 'DD-MON-YYYY'), 
    TermEnd = ADD_MONTHS(TO_DATE('01-JUL-2024', 'DD-MON-YYYY'), 30),  -- 30 months (2.5 years) from TermStart 
    TermStart = (SELECT COALESCE(MAX(TermEnd) + 1, TO_DATE('01-JUL-2024', 'DD-MON-YYYY')) 
                 FROM Elected_Official e2 
                 WHERE e1.ConstituencyID = e2.ConstituencyID 
                   AND e2.TermEnd < TO_DATE('01-JUL-2024', 'DD-MON-YYYY')) 
WHERE ElectedOfficialID IN ( 
    SELECT e.ElectedOfficialID 
    FROM Elected_Official e 
    JOIN ( 
        SELECT ConstituencyID, MAX(VotesReceived) AS MaxVotes 
        FROM ( 
            SELECT par.ConstituencyID, par.VotesReceived 
            FROM province_assembly_result par 
            UNION ALL 
            SELECT nar.ConstituencyID, nar.VotesReceived 
            FROM national_assembly_result nar 
        ) combined_results 
        GROUP BY ConstituencyID 
        HAVING COUNT(*) = 2  -- Two candidates with the same max votes in the constituency 
    ) sub ON e.ConstituencyID = sub.ConstituencyID AND e.VotesReceived = sub.MaxVotes 
);

UPDATE Elected_Official e1 
SET TermStart = TO_DATE('01-JUL-2024', 'DD-MON-YYYY'), 
    TermEnd = ADD_MONTHS(TO_DATE('01-JUL-2024', 'DD-MON-YYYY'), 30),  -- 30 months (2.5 years) from TermStart 
    TermStart = (SELECT COALESCE(MAX(TermEnd) + 1, TO_DATE('01-JUL-2024', 'DD-MON-YYYY')) 
                 FROM Elected_Official e2 
                 WHERE e1.ConstituencyID = e2.ConstituencyID 
                   AND e2.TermEnd < TO_DATE('01-JUL-2024', 'DD-MON-YYYY')) 
WHERE ElectedOfficialID IN ( 
    SELECT e.ElectedOfficialID 
    FROM Elected_Official e 
    JOIN ( 
        SELECT ConstituencyID, MAX(VotesReceived) AS MaxVotes 
        FROM ( 
            SELECT par.ConstituencyID, par.VotesReceived 
            FROM province_assembly_result par 
            UNION ALL 
            SELECT nar.ConstituencyID, nar.VotesReceived 
            FROM national_assembly_result nar 
        ) combined_results 
        GROUP BY ConstituencyID 
        HAVING COUNT(*) = 2  -- Two candidates with the same max votes in the constituency 
    ) sub ON e.ConstituencyID = sub.ConstituencyID AND e.VotesReceived = sub.MaxVotes 
);

select * from elected_officiAL order by constituencyid;

WITH UpdatedOfficials AS ( 
    -- Update TermEnd to 1st January 2027 for candidates with specific conditions 
    UPDATE Elected_Official e1 
    SET TermEnd = TO_DATE('01-JAN-2027', 'DD-MON-YYYY') 
    WHERE ElectedOfficialID IN ( 
        SELECT e.ElectedOfficialID 
        FROM Elected_Official e 
        JOIN ( 
            SELECT ConstituencyID, MAX(VotesReceived) AS MaxVotes 
            FROM ( 
                SELECT par.ConstituencyID, par.VotesReceived 
                FROM province_assembly_result par 
                UNION ALL 
                SELECT nar.ConstituencyID, nar.VotesReceived 
                FROM national_assembly_result nar 
            ) combined_results 
            GROUP BY ConstituencyID 
            -- Add additional conditions here if needed 
            HAVING COUNT(*) = 1  -- Update TermEnd for specific candidates 
        ) sub ON e.ConstituencyID = sub.ConstituencyID AND e.VotesReceived = sub.MaxVotes 
        RETURNING e1.ConstituencyID, e1.TermEnd 
    ) 
) 
-- Update TermStart to 2nd January 2027 and TermEnd to 30th June 2029 for the next candidate 
UPDATE Elected_Official e2 
SET TermStart = TO_DATE('02-JAN-2027', 'DD-MON-YYYY'), 
    TermEnd = TO_DATE('30-JUN-2029', 'DD-MON-YYYY') 
WHERE EXISTS ( 
    SELECT 1 
    FROM UpdatedOfficials 
    WHERE e2.ConstituencyID = UpdatedOfficials.ConstituencyID 
)


COMMIT;

WITH UpdatedOfficials AS ( 
    -- Update TermEnd to 1st January 2027 for candidates with specific conditions 
    UPDATE Elected_Official e1 
    SET TermEnd = TO_DATE('01-JAN-2027', 'DD-MON-YYYY') 
    WHERE ElectedOfficialID IN ( 
        SELECT e.ElectedOfficialID 
        FROM Elected_Official e 
        JOIN ( 
            SELECT ConstituencyID, MAX(VotesReceived) AS MaxVotes 
            FROM ( 
                SELECT par.ConstituencyID, par.VotesReceived 
                FROM province_assembly_result par 
                UNION ALL 
                SELECT nar.ConstituencyID, nar.VotesReceived 
                FROM national_assembly_result nar 
            ) combined_results 
            GROUP BY ConstituencyID 
            -- Add additional conditions here if needed 
            HAVING COUNT(*) = 1  -- Update TermEnd for specific candidates 
        ) sub ON e.ConstituencyID = sub.ConstituencyID AND e.VotesReceived = sub.MaxVotes 
        RETURNING e1.ConstituencyID, e1.TermEnd 
    ) 
)


UPDATE Elected_Official e1 
SET TermEnd = TO_DATE('01-JAN-2027', 'DD-MON-YYYY') 
WHERE ElectedOfficialID IN ( 
    SELECT e.ElectedOfficialID 
    FROM Elected_Official e 
    JOIN ( 
        SELECT ConstituencyID, MAX(VotesReceived) AS MaxVotes 
        FROM ( 
            SELECT par.ConstituencyID, par.VotesReceived 
            FROM province_assembly_result par 
            UNION ALL 
            SELECT nar.ConstituencyID, nar.VotesReceived 
            FROM national_assembly_result nar 
        ) combined_results 
        GROUP BY ConstituencyID 
        HAVING COUNT(*) = 1  -- Update TermEnd for specific candidates 
    ) sub ON e.ConstituencyID = sub.ConstituencyID AND e.VotesReceived = sub.MaxVotes 
);

COMMIT;

UPDATE Elected_Official e2 
SET TermStart = TO_DATE('02-JAN-2027', 'DD-MON-YYYY'), 
    TermEnd = TO_DATE('30-JUN-2029', 'DD-MON-YYYY') 
WHERE TermEnd = TO_DATE('01-JAN-2027', 'DD-MON-YYYY')  -- Select candidates updated in the previous step 
AND EXISTS ( 
    SELECT 1 
    FROM Elected_Official e3 
    WHERE e3.ConstituencyID = e2.ConstituencyID 
    AND e3.TermStart = TO_DATE('01-JAN-2027', 'DD-MON-YYYY')  -- Ensure we're updating the next candidate 
);

COMMIT;

select * from elected_officiAL order by constituencyid;

truncate table elected_official


INSERT INTO Elected_Official (ElectedOfficialID, PartyID, ConstituencyID, VotesReceived, ElectedOfficialName, TermStart, TermEnd)  
SELECT elected_official_seq.NEXTVAL,  
       c.Party_ID,  
       par.ConstituencyID,  
       par.VotesReceived,  
       par.CandidateName,  
       TO_DATE('01-JUL-2024', 'DD-MON-YYYY'),  -- TermStart set to 01-JUL-2024  
       TO_DATE('30-JUN-2029', 'DD-MON-YYYY')                                    -- TermEnd is unknown at this time  
FROM province_assembly_result par  
JOIN Candidate c ON par.CandidateID = c.candidate_ID  
WHERE (par.ConstituencyID, par.VotesReceived) IN (  
    SELECT ConstituencyID, MAX(VotesReceived)  
    FROM province_assembly_result  
    GROUP BY ConstituencyID  
);

INSERT INTO Elected_Official (ElectedOfficialID, PartyID, ConstituencyID, VotesReceived, ElectedOfficialName, TermStart, TermEnd) 
SELECT elected_official_seq.NEXTVAL, 
       c.Party_ID, 
       nar.ConstituencyID, 
       nar.VotesReceived, 
       nar.CandidateName, 
       TO_DATE('01-JUL-2024', 'DD-MON-YYYY'),  -- TermStart set to 01-JUL-2024 
       TO_DATE('30-JUN-2029', 'DD-MON-YYYY')  -- TermEnd set to 01-JUL-2029 
FROM national_assembly_result nar 
JOIN Candidate c ON nar.CandidateID = c.candidate_ID 
WHERE (nar.ConstituencyID, nar.VotesReceived) IN ( 
    SELECT ConstituencyID, MAX(VotesReceived) 
    FROM national_assembly_result 
    GROUP BY ConstituencyID 
);

select * from elected_officiAL order by constituencyid;

select * from elected_officiAL order by constituencyid;

UPDATE Elected_Official 
SET TermEnd = TO_DATE('01-JAN-2027', 'DD-MON-YYYY') 
WHERE ELECTEDOFFICIALID = 222;

select * from elected_officiAL order by constituencyid;

UPDATE Elected_Official 
SET TermEnd = TO_DATE('31-DEC-2026', 'DD-MON-YYYY') 
WHERE ELECTEDOFFICIALID = 222 
;

select * from elected_officiAL order by constituencyid;

UPDATE Elected_Official 
SET TermStart = TO_DATE('01-JAN-2026', 'DD-MON-YYYY') 
WHERE ELECTEDOFFICIALID = 216;

select * from elected_officiAL order by constituencyid;

UPDATE Elected_Official 
SET TermStart = TO_DATE('01-JAN-2027', 'DD-MON-YYYY') 
WHERE ELECTEDOFFICIALID = 216;

select * from elected_officiAL order by constituencyid;

UPDATE Elected_Official 
SET TermEnd = TO_DATE('28-FEB-2026', 'DD-MON-YYYY') 
WHERE ELECTEDOFFICIALID = 205 
 
UPDATE Elected_Official 
SET TermStart = TO_DATE('01-MAR-2026', 'DD-MON-YYYY') 
WHERE ELECTEDOFFICIALID = 223 
 
    UPDATE Elected_Official 
SET TermEnd = TO_DATE('31-OCT-2027', 'DD-MON-YYYY') 
WHERE ELECTEDOFFICIALID = 223 
 
UPDATE Elected_Official 
SET TermStart = TO_DATE('01-NOV-2027', 'DD-MON-YYYY') 
WHERE ELECTEDOFFICIALID = 225 
 
    UPDATE Elected_Official 
SET TermEnd = TO_DATE('30-JUN-2029', 'DD-MON-YYYY') 
WHERE ELECTEDOFFICIALID = 225;

UPDATE Elected_Official 
SET TermEnd = TO_DATE('28-FEB-2026', 'DD-MON-YYYY') 
WHERE ELECTEDOFFICIALID = 205;

UPDATE Elected_Official 
SET TermStart = TO_DATE('01-MAR-2026', 'DD-MON-YYYY') 
WHERE ELECTEDOFFICIALID = 223;

    UPDATE Elected_Official 
SET TermEnd = TO_DATE('31-OCT-2027', 'DD-MON-YYYY') 
WHERE ELECTEDOFFICIALID = 223;

UPDATE Elected_Official 
SET TermStart = TO_DATE('01-NOV-2027', 'DD-MON-YYYY') 
WHERE ELECTEDOFFICIALID = 225;

    UPDATE Elected_Official 
SET TermEnd = TO_DATE('30-JUN-2029', 'DD-MON-YYYY') 
WHERE ELECTEDOFFICIALID = 225;

select * from elected_officiAL order by constituencyid;

select * from elected_officiAL order by constituencyid;

UPDATE Elected_Official 
SET TermEnd = TO_DATE('28-FEB-2026', 'DD-MON-YYYY') 
WHERE ELECTEDOFFICIALID = 221;

UPDATE Elected_Official 
SET TermStart = TO_DATE('01-MAR-2026', 'DD-MON-YYYY') 
WHERE ELECTEDOFFICIALID = 209;

    UPDATE Elected_Official 
SET TermEnd = TO_DATE('31-OCT-2027', 'DD-MON-YYYY') 
WHERE ELECTEDOFFICIALID = 209;

UPDATE Elected_Official 
SET TermStart = TO_DATE('01-NOV-2027', 'DD-MON-YYYY') 
WHERE ELECTEDOFFICIALID = 210;

    UPDATE Elected_Official 
SET TermEnd = TO_DATE('30-JUN-2029', 'DD-MON-YYYY') 
WHERE ELECTEDOFFICIALID = 210;

select * from elected_officiAL order by constituencyid;

UPDATE Elected_Official 
SET TermEnd = TO_DATE('28-FEB-2026', 'DD-MON-YYYY') 
WHERE ELECTEDOFFICIALID = 245;

UPDATE Elected_Official 
SET TermStart = TO_DATE('01-MAR-2026', 'DD-MON-YYYY') 
WHERE ELECTEDOFFICIALID = 241;

    UPDATE Elected_Official 
SET TermEnd = TO_DATE('31-OCT-2027', 'DD-MON-YYYY') 
WHERE ELECTEDOFFICIALID = 241;

UPDATE Elected_Official 
SET TermStart = TO_DATE('01-NOV-2027', 'DD-MON-YYYY') 
WHERE ELECTEDOFFICIALID = 231;

    UPDATE Elected_Official 
SET TermEnd = TO_DATE('30-JUN-2029', 'DD-MON-YYYY') 
WHERE ELECTEDOFFICIALID = 231;

select * from elected_officiAL order by constituencyid;

UPDATE Elected_Official 
SET TermEnd = TO_DATE('31-DEC-2026', 'DD-MON-YYYY') 
WHERE ELECTEDOFFICIALID = 214;

UPDATE Elected_Official 
SET TermStart = TO_DATE('01-JAN-2027', 'DD-MON-YYYY') 
WHERE ELECTEDOFFICIALID = 219;

select * from elected_officiAL order by constituencyid;

UPDATE Elected_Official 
SET TermEnd = TO_DATE('31-DEC-2026', 'DD-MON-YYYY') 
WHERE ELECTEDOFFICIALID = 226;

UPDATE Elected_Official 
SET TermStart = TO_DATE('01-JAN-2027', 'DD-MON-YYYY') 
WHERE ELECTEDOFFICIALID = 224;

select * from elected_officiAL order by constituencyid;

UPDATE Elected_Official 
SET TermEnd = TO_DATE('31-DEC-2026', 'DD-MON-YYYY') 
WHERE ELECTEDOFFICIALID = 215;

UPDATE Elected_Official 
SET TermStart = TO_DATE('01-JAN-2027', 'DD-MON-YYYY') 
WHERE ELECTEDOFFICIALID = 207;

select * from elected_officiAL order by constituencyid;

UPDATE Elected_Official 
SET TermEnd = TO_DATE('31-DEC-2026', 'DD-MON-YYYY') 
WHERE ELECTEDOFFICIALID = 218;

UPDATE Elected_Official 
SET TermStart = TO_DATE('01-JAN-2027', 'DD-MON-YYYY') 
WHERE ELECTEDOFFICIALID = 212;

select * from elected_officiAL order by constituencyid;

select * from elected_officiAL order by constituencyid;

UPDATE Elected_Official 
SET TermEnd = TO_DATE('31-DEC-2026', 'DD-MON-YYYY') 
WHERE ELECTEDOFFICIALID = 247;

UPDATE Elected_Official 
SET TermStart = TO_DATE('01-JAN-2027', 'DD-MON-YYYY') 
WHERE ELECTEDOFFICIALID = 227;

select * from elected_officiAL order by constituencyid;

UPDATE Elected_Official 
SET TermEnd = TO_DATE('31-DEC-2026', 'DD-MON-YYYY') 
WHERE ELECTEDOFFICIALID = 236;

UPDATE Elected_Official 
SET TermStart = TO_DATE('01-JAN-2027', 'DD-MON-YYYY') 
WHERE ELECTEDOFFICIALID = 239;

UPDATE Elected_Official 
SET TermEnd = TO_DATE('31-DEC-2026', 'DD-MON-YYYY') 
WHERE ELECTEDOFFICIALID = 244;

UPDATE Elected_Official 
SET TermStart = TO_DATE('01-JAN-2027', 'DD-MON-YYYY') 
WHERE ELECTEDOFFICIALID = 243;

UPDATE Elected_Official 
SET TermEnd = TO_DATE('31-DEC-2026', 'DD-MON-YYYY') 
WHERE ELECTEDOFFICIALID = 238;

UPDATE Elected_Official 
SET TermStart = TO_DATE('01-JAN-2027', 'DD-MON-YYYY') 
WHERE ELECTEDOFFICIALID = 237;

select * from elected_officiAL order by constituencyid;

UPDATE Elected_Official 
SET TermEnd = TO_DATE('31-DEC-2026', 'DD-MON-YYYY') 
WHERE ELECTEDOFFICIALID = 232;

UPDATE Elected_Official 
SET TermStart = TO_DATE('01-JAN-2027', 'DD-MON-YYYY') 
WHERE ELECTEDOFFICIALID = 249;

UPDATE Elected_Official 
SET TermEnd = TO_DATE('31-DEC-2026', 'DD-MON-YYYY') 
WHERE ELECTEDOFFICIALID = 228;

UPDATE Elected_Official 
SET TermStart = TO_DATE('01-JAN-2027', 'DD-MON-YYYY') 
WHERE ELECTEDOFFICIALID = 230;

SELECT  
    PartyID, 
    ConstituencyID, 
    VotesReceived, 
    ElectedOfficialName, 
    TermStart, 
    TermEnd 
FROM  
    Elected_Official 
WHERE  
    VotesReceived = ( 
        SELECT MIN(VotesReceived) 
        FROM Elected_Official 
    );

SELECT  
    PartyID, 
    ConstituencyID, 
    VotesReceived, 
    ElectedOfficialName, 
    TermStart, 
    TermEnd 
FROM  
    Elected_Official 
WHERE  
    VotesReceived = ( 
        SELECT MAX(VotesReceived) 
        FROM Elected_Official 
    );

SELECT  
    v.VOTERID, 
    v.CITY, 
    v.GENDER AS VoterGender, 
    v.STATE, 
    v.EMAIL, 
    v.NAME AS VoterName, 
    v.CNIC, 
    v.DATEOFBIRTH AS VoterDOB, 
    v.FAMILY_ID, 
    fmr.MEMBERID, 
    fmr.GENDER AS FamilyMemberGender, 
    fmr.CNIC AS FamilyMemberCNIC, 
    fmr.DATEOFBIRTH AS FamilyMemberDOB, 
    fmr.FAMILY_ID AS FamilyMemberFamilyID 
FROM  
    Voter v 
JOIN  
    Family_Member_Record fmr ON v.VOTERID = fmr.VOTER_ID;

SELECT  
    f.FAMILYID, 
    f.FAMILY_MEMBER_NAME, 
    fmr.MEMBERID, 
    fmr.GENDER, 
    fmr.CNIC, 
    fmr.DATEOFBIRTH, 
    fmr.VOTER_ID 
FROM  
    Family f 
JOIN  
    Family_Member_Record fmr ON f.FAMILYID = fmr.FAMILY_ID;

SELECT  
    c.candidate_ID, 
    c.Name AS CandidateName, 
    c.date_of_birth, 
    c.gender, 
    c.religion, 
    p.party_ID, 
    p.party_name, 
    p.chairperson_name, 
    p.contact_info, 
    p.headquarters 
FROM  
    Candidate c 
JOIN  
    Political_Party p ON c.party_ID = p.party_ID;

