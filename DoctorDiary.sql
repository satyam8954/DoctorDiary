create database DoctorDiaryDB
go

Create Sequence Sequence_Doctor
Start with 1000
Increment by 1
MaxValue 9999;
go

Create Sequence Sequence_Patient
Start with 100000
Increment by 1
MaxValue 999999;
go

Create Sequence Sequence_Appointment
Start with 100000
Increment by 1
MaxValue 999999;
go

Create Sequence Sequence_License
Start with 100000
Increment by 1
MaxValue 999999;
go

Create Sequence Sequence_Hospital
Start with 1000
Increment by 1
MaxValue 2000;
go

Create Sequence Sequence_Medicine
Start with 1000
Increment by 1
MaxValue 9999;
go


create table [User]
(
EmailId varchar(50) Not null,
[Password] varchar(20) not null,
[Role] char(1) not null
Constraint PK_User Primary Key (EmailId)
)

create table License
(
LicenseId char(7) not null,
DoctorName Varchar(20) not null,
Degree Varchar(10) not null,
Gender char(1) not null,
SpecializationName varchar(15) not null,
Dob Date not null,
LID date not null 
Constraint PK_License Primary Key (LicenseId)

)

create table Doctor
(
DoctorId char(5) not null,
DoctorName Varchar(20) not null,
Gender Char(1) not null,
EmailId varchar(50) not null,
Dob Date not null,
HospitalId char(5) not null,
SpecializationName varchar(15) not null,
MorningSlot varchar(15) not null,
EveningSlot varchar(15) not null,
LicenseId char(7) not null,
Constraint PK_Doctor Primary Key (DoctorId),
Constraint FK_Doctor Foreign Key (LicenseId) References License (LicenseId)
)

Create Table Patient
(
PatientId char(7) not null,
PatientName varchar(20) not null,
EmailId varchar(50) not null,
Gender char(1) Not null,
Age int not null,
Contact numeric(10) not null,
Constraint PK_Patient Primary Key (PatientId),
Constraint UN_Patient Unique (EmailId)
)

Create Table Hospital
(
HospitalId char(5) not null,
HospitalName varchar(30) not null,
HospitalAddress Varchar(50) not null,
City Varchar(20) not null,
Pincode numeric(6) not null,
Constraint PK_Hospital Primary Key (HospitalId)
)

Create Table Medicine
(
MedicineId char(7) not null,
MedicineName Varchar(30) not null,
Constraint PK_Medicine Primary Key (MedicineId)
)

Create Table Prescription
(
PatientId Char(7) not null,
DoctorId Char(5) not null,
MedicineName Varchar(30) not null,
Slot char(3) not null,
Quantity float not null,
Constraint PK_Prescription Primary Key (PatientId,DoctorId,MedicineName),
Constraint FK_Prescription1 Foreign Key (PatientId) References Patient (PatientId),
Constraint FK_Prescription2 Foreign Key (DoctorId) References Doctor (DoctorId)
)

Create Table Appointment
(
AppointmentId char(7) not null,
DoctorId char(5) not null,
PatientId char(7) not null,
AppointmentSlot char(3) not null
Constraint PK_Appointment Primary Key (AppointmentId),
Constraint FK_Appointment1 Foreign Key (PatientId) References Patient (PatientId),
Constraint FK_Appointment2 Foreign Key (DoctorId) References Doctor (DoctorId)
)

Create Table Feedback
(
DoctorId char(5) not null,
PatientId char(7) not null,
Feedback varchar(100),
Rating tinyInt,
Constraint PK_Feedback Primary Key (DoctorId,PatientId),
Constraint FK_Feedback1 Foreign Key (PatientId) References Patient (PatientId),
Constraint FK_Feedback2 Foreign Key (DoctorId) References Doctor (DoctorId)
)

Create Table Detail
(
PatientId char(7) not null,
DoctorId char(5) not null,
Remark varchar(100) not null,
Meds varchar(70) not null,
Reference char(5),
Constraint PK_Detail Primary Key (DoctorId,PatientId),
Constraint FK_Detail1 Foreign Key (PatientId) References Patient (PatientId),
Constraint FK_Detail2 Foreign Key (DoctorId) References Doctor (DoctorId)
)

create Procedure usp_Insert_User (@emaiId varchar(50), @password varchar(20), @role char(1))
as
begin

	Insert into [User](EmailId, [Password], [Role])
	            values (@emaiId, @password, @role)

end
go

alter Procedure usp_Insert_License (@doctorName varchar(20), @degree varchar (10), @gender char(1),
                                     @specializationName varchar(15), @dob date, @lid date)
as
begin
	declare @licenseId char(7),
		    @nextValue int = Next value For Sequence_License

	select @licenseId = 'L' + convert (char(6),@nextValue) 

	Insert into License(LicenseId, DoctorName, Degree, Gender, SpecializationName, Dob, LID)
	            values (@licenseId, @doctorName, @degree, @gender, @specializationName, @dob, @lid)

end
go

alter Procedure usp_Insert_Doctor (@emailId varchar(50), @hospitalId char(5), @morningSlot varchar(15), 
@eveningSlot varchar(15), @licenseId char(7))
as
begin
Declare @doctorName varchar(20),
        @gender char(1),
		@dob date,
		@specailizationName varchar(15),
		@doctorId char(5),
		@nextValue int = Next value For Sequence_Doctor

	select @doctorName=DoctorName,@gender=Gender,@dob=Dob,@specailizationName=SpecializationName
	            from License where @licenseId=LicenseId

	select @doctorId = 'D' + convert (char(4),@nextValue) 

	Insert into Doctor(DoctorId, DoctorName, Gender, EmailId, Dob, HospitalId, SpecializationName, MorningSlot,
	                   EveningSlot, LicenseId) 
	            values(@doctorId, @doctorName, @gender, @emailId, @dob, @hospitalId, @specailizationName,
	                          @morningSlot, @eveningSlot, @licenseId)
end
go

create Procedure usp_Insert_Hospital (@hospitalName varchar(30), @hospitalAddress varchar(50), @city varchar(20),
                                      @pincode Numeric(6))
as
begin
declare @hospitalId char(5),
        @nextValue int = Next Value For Sequence_Hospital

	select @hospitalId = 'H' + convert (char(4),@nextValue)

	Insert into Hospital(HospitalId, HospitalName, HospitalAddress, City, Pincode)
	            values (@hospitalId, @hospitalName, @hospitalAddress, @city, @pincode)

end
go

create Procedure usp_Insert_Medicine (@medicineName varchar(30))
as
begin
declare @medicineId char(5),
        @nextValue int = Next Value For Sequence_Medicine

	select @medicineId = 'M' + convert (char(4),@nextValue)

	Insert into Medicine(MedicineId, MedicineName)
	            values (@medicineId, @medicineName)

end
go

create Procedure usp_Insert_Prescription (@patientId char(7), @doctorId char(5),@medicineName varchar(30), 
                                          @slot char(3), @quantity float )
as
begin

	Insert into Prescription(PatientId, DoctorId, MedicineName, Slot, Quantity)
	            values (@patientId,@doctorId, @medicineName, @slot, @quantity)

end
go

alter Procedure usp_Insert_Patient (@patientName varchar(20), @emailId varchar(50), @gender char(1), @age int,
                                      @contact Numeric(10))
as
begin
declare @patientId char(7),
        @nextValue int = Next Value For Sequence_Patient

	select @patientId = 'P' + convert (char(6),@nextValue)

	Insert into Patient(PatientId, PatientName, EmailId, Gender, Age, Contact)
	            values (@patientId, @patientName, @emailId, @gender, @age, @contact)

end
go

alter Procedure usp_Insert_Appointment (@doctorId char(5), @patientId char(7), @appointmentSlot char(3))
as
begin
declare @appointmentId char(7),
        @nextValue int = Next Value For Sequence_Appointment

	select @appointmentId = 'A' + convert (char(6),@nextValue)

	Insert into Appointment(AppointmentId, DoctorId, PatientId, AppointmentSlot)
	            values (@appointmentId, @doctorId, @patientId, @appointmentSlot)

end
go

create Procedure usp_Insert_Feedback (@doctorId char(5), @patientId char(7), 
                                      @feedback varchar(100), @rating tinyint)
as
begin

	Insert into Feedback(DoctorId, PatientId, Feedback,	Rating)
	            values (@doctorId, @patientId, @feedback, @rating)

end
go

create Procedure usp_Insert_Detail (@patientId char(7), @doctorId char(5), @remark varchar(100), 
                                    @meds varchar(70), @reference char(5))
as
begin

	Insert into Detail(PatientId, DoctorId, Remark, Meds, Reference)
	            values (@patientId, @doctorId, @remark, @meds, @reference)

end
go

exec usp_Insert_User 'abcd.gmail.com', '1234567', 'P'


exec usp_Insert_License 'Deepak Goswami', 'M.D.', 'M', 'Neuro Surgeon', '1985-12-11', '2014-03-24'
select * from License

exec usp_Insert_Doctor 'abcd.gmail.com', 'H1001' , '9-12', '5-8', 'L100002'
select * from Doctor

exec usp_Insert_Medicine 'ACARBOSE-50mg'
exec usp_Insert_Medicine 'ACETAZOLAMIDE-1000mg'
exec usp_Insert_Medicine 'ACYCLOVIR-200mg'
exec usp_Insert_Medicine 'ALBENDAZOLE-400mg'
exec usp_Insert_Medicine 'AMANTADINE-200mg'
exec usp_Insert_Medicine 'AMOXYCILLIN-500mg'
exec usp_Insert_Medicine 'AMPICILLIN-1000mg'
exec usp_Insert_Medicine 'AMYLASE-10mg'
exec usp_Insert_Medicine 'BISOPROLOL-20mg'
exec usp_Insert_Medicine 'CARBAMAZEPINE-1600mg'
exec usp_Insert_Medicine 'DIPYRIDAMOLE-600mg'
exec usp_Insert_Medicine 'OLANZAPINE-10mg'
exec usp_Insert_Medicine 'PIROXICAM-30mg'
exec usp_Insert_Medicine 'PRAVASTATIN-40mg'
exec usp_Insert_Medicine 'ASPIRIN-50mg'
exec usp_Insert_Medicine 'ATROPINE-2mg'
exec usp_Insert_Medicine 'BACLOFEN-15mg'
exec usp_Insert_Medicine 'BETAHISTINE-16mg'
exec usp_Insert_Medicine 'BUPIVACAINE HCL-150mg'
exec usp_Insert_Medicine 'CALCIPOTRIOL-15mg'
exec usp_Insert_Medicine 'CARBOPLATIN-360mg'
exec usp_Insert_Medicine 'CARVEDILOL-25mg'
exec usp_Insert_Medicine 'CEFIXIME-400mg'
exec usp_Insert_Medicine 'CEFTIZOXIME-10mg'
exec usp_Insert_Medicine 'CETIRIZINE-10mg'
exec usp_Insert_Medicine 'CLINDAMYCIN-300mg'
exec usp_Insert_Medicine 'CLOXACILLIN-500mg'
exec usp_Insert_Medicine 'DICYCLOMINE-20mg'
exec usp_Insert_Medicine 'DINOPROSTONE-15mg'
exec usp_Insert_Medicine 'DIOSMIN-300mg'
exec usp_Insert_Medicine 'DISOPYRAMIDE-150mg'
exec usp_Insert_Medicine 'DOXAZOSIN-10mg'
exec usp_Insert_Medicine 'DOXEPIN-100mg'
exec usp_Insert_Medicine 'ERYTHROMYCIN-250mg'
exec usp_Insert_Medicine 'FLAVOXATE-200mg'
exec usp_Insert_Medicine 'FLUCONAZOL-500mg'
exec usp_Insert_Medicine 'GLICLAZIDE-80mg'
exec usp_Insert_Medicine 'INDAPAMIDE-2.5mg'
exec usp_Insert_Medicine 'KETAMINE-5mg'
exec usp_Insert_Medicine 'LORATADINE-5-10mg'
exec usp_Insert_Medicine 'MIDAZOLAM-20mg'
exec usp_Insert_Medicine 'NALOXONE-10mg'
exec usp_Insert_Medicine 'NIMESULIDE-100mg'
exec usp_Insert_Medicine 'NYSTATIN-100ml'
exec usp_Insert_Medicine 'OFLOXACIN-400mg'
exec usp_Insert_Medicine 'ORNIDAZOLE-500mg'
exec usp_Insert_Medicine 'OXAZEPAM-30mg'
exec usp_Insert_Medicine 'PANCREATIN-600mg'
exec usp_Insert_Medicine 'PINDOLOL-40mg'
exec usp_Insert_Medicine 'PIRIBEDIL-10mg'
exec usp_Insert_Medicine 'PRAZOSIN-15mg'
exec usp_Insert_Medicine 'PRIMIDONE-20mg'
exec usp_Insert_Medicine 'RAMPIRIL-1.25mg'
exec usp_Insert_Medicine 'RUTIN-40mg'
exec usp_Insert_Medicine 'RIBAVIRIN-200mg'
exec usp_Insert_Medicine 'SISOMICIN-3mg'
exec usp_Insert_Medicine 'SOFRAMYCIN-1mg'
exec usp_Insert_Medicine 'SPIRULINA-40mg'
exec usp_Insert_Medicine 'SUCRALAFATE-1gm'
exec usp_Insert_Medicine 'SUMATRIPTAN-40mg'
exec usp_Insert_Medicine 'TAMOXIFEN-20mg'
exec usp_Insert_Medicine 'TERAZOSIN-20mg'
exec usp_Insert_Medicine 'TETRACYCLINE-2gm'
exec usp_Insert_Medicine 'TIMOLOL-2ml'
exec usp_Insert_Medicine 'TOLNAFTATE-40mg'
exec usp_Insert_Medicine 'TRICLOFOS-150mg'
exec usp_Insert_Medicine 'UROKINASE-80mg'
exec usp_Insert_Medicine 'VALETHAMATE-8mg'
exec usp_Insert_Medicine 'VERAPAMIL-480mg'
exec usp_Insert_Medicine 'WARFARIN-15mg'
exec usp_Insert_Medicine 'XIPAMIDE-40mg'
exec usp_Insert_Medicine 'ZOPICLONE-15mg'
select * from Medicine



select * from [User]

								       
 updated
