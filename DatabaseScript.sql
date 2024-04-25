--------------create database-------------------
IF db_id('TestClients') IS NULL 
    CREATE DATABASE TestClients
GO
--------------use database-------------------
USE [TestClients]
GO
--------------create table-------------------
IF NOT  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Clients]') AND type in (N'U'))
begin
	CREATE TABLE [dbo].[Clients](
		[id_PK] [int] IDENTITY(1,1) NOT NULL,
		[ClientNumber] [int] NOT NULL,
		[Name] [nvarchar](20) NULL,
		[BirthDay] [datetime] NULL,
	 CONSTRAINT [PK_Clients] PRIMARY KEY CLUSTERED 
	(
		[ClientNumber] ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [Data]
	) ON [Data]
end
GO
--------------create table-------------------
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Addresses]') AND type in (N'U'))
begin
	CREATE TABLE [dbo].[Addresses](
		[id_PK] [int] IDENTITY(1,1) NOT NULL,
		[Type] [int] NOT NULL,
		[Adress] [nvarchar](200) NULL,
	 CONSTRAINT [PK_Addresses] PRIMARY KEY CLUSTERED 
	(
		[id_PK] ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [Data]
	) ON [Data]
end
GO
--------------create table-----------
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ClientAddress]') AND type in (N'U'))
begin
	CREATE TABLE [dbo].[ClientAddress](
		[id_PK] [int] IDENTITY(1,1) NOT NULL,
		[IdClient] [int] NOT NULL,
		[IdAdress] [int] NOT NULL,
		[AdressData] [nvarchar](200) NULL,
	 CONSTRAINT [id_PK] PRIMARY KEY CLUSTERED 
	(
		[id_PK] ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [Data]
	) ON [Data]
	
	ALTER TABLE [dbo].[ClientAddress]  WITH CHECK ADD  CONSTRAINT [FK_IdAdress] FOREIGN KEY([IdAdress])
	REFERENCES [dbo].[Addresses] ([id_PK])
	ALTER TABLE [dbo].[ClientAddress] CHECK CONSTRAINT [FK_IdAdress]
	ALTER TABLE [dbo].[ClientAddress]  WITH CHECK ADD  CONSTRAINT [FK_IdClient] FOREIGN KEY([IdClient])
	REFERENCES [dbo].[Clients] ([ClientNumber])
	ALTER TABLE [dbo].[ClientAddress] CHECK CONSTRAINT [FK_IdClient]
end
GO
--------------create procedure p_ClientsGet-----------

IF  EXISTS (SELECT type_desc, type FROM sys.procedures WITH(NOLOCK) WHERE NAME = 'p_ClientsGet' AND type = 'P')
	DROP PROCEDURE [dbo].[p_ClientsGet]	
GO

CREATE PROCEDURE  [dbo].[p_ClientsGet]
AS
BEGIN
	
	select
		cl.[ClientNumber] as ID,
		cl.name as Name,
		cl.BirthDay as BirthDate,	
		( STUFF((SELECT  ';' +isnull(Ad.Adress,'')+'-' + isnull(AdressData,'') from [dbo].[ClientAddress] cAD 
			inner join [dbo].[Addresses] Ad on Ad.[id_PK]  = cAd.[IdAdress]
			where   cAd.[IdClient] = cl.ClientNumber FOR XML PATH(''), TYPE ).value('.', 'NVARCHAR(MAX)') ,1,1,'') ) as AdressData
	from
		dbo.Clients cl 
		
	

END
GO
--------------create procedure p_ClientsInsertFromXML-----------
IF EXISTS (SELECT type_desc, type FROM sys.procedures WITH(NOLOCK) WHERE NAME = 'p_ClientsInsertFromXML' AND type = 'P')
	DROP PROCEDURE [dbo].[p_ClientsInsertFromXML]
GO

CREATE PROCEDURE  [dbo].[p_ClientsInsertFromXML]
(
			@p_xmlInput varchar(max)			
)
AS
BEGIN
declare @p_xml xml
set @p_xml=CAST(@p_xmlInput as Xml)
declare @flag bit = 1;
	begin try
		--test example
		/*DECLARE @p_xml XML = '<Clients>
		<Client ID="12345">
			<Name>Ime1</Name>
			<Addresses>
				<Address Type="1">Partizanska</Address>
				<Address Type="2">Boris Trajkovski</Address>
			</Addresses>
			<BirthDate>2001-09-01</BirthDate>
		</Client>
		<Client ID="54321">
			<Name>Ime2</Name>
			<Addresses>
				<Address Type="1">Goce Delcev</Address>
			</Addresses>
			<BirthDate>2003-09-01</BirthDate>
		</Client>
		</Clients>'*/
	

		DECLARE   @Client TABLE (
			ID INT,
			Name NVARCHAR(100),
			BirthDate DATE
		)

		declare @Address TABLE (
			ID INT IDENTITY(1,1) PRIMARY KEY,
			ClientID INT,
			Address NVARCHAR(100),
			AddressType INT
		)

	
		INSERT INTO @Client (ID, Name, BirthDate)
		SELECT 
			c.value('@ID', 'int') AS ID,
			c.value('(Name)[1]', 'nvarchar(100)') AS Name,
			c.value('(BirthDate)[1]', 'date') AS BirthDate
		FROM 
			@p_xml.nodes('/Clients/Client') AS t(c)

	
		INSERT INTO @Address (ClientID, Address, AddressType)
		SELECT 
			c.value('@ID', 'int')  AS ClientID,
			a.value('(text())[1]', 'nvarchar(100)') AS Address,
			a.value('@Type', 'int') AS AddressType
		FROM 
			@p_xml.nodes('/Clients/Client') AS t(c)
		OUTER APPLY 
			c.nodes('Addresses/Address') AS Addr(a)

		--SELECT * FROM @Client
		--SELECT * FROM @Address

		INSERT [dbo].[Clients] ([ClientNumber],[Name],[BirthDay])
		SELECT  ID,Name,BirthDate
		FROM @Client cr
		WHERE
		   NOT EXISTS (SELECT * FROM  [dbo].[Clients] c
					  WHERE cr.ID = c.[ClientNumber] )


		INSERT [dbo].[ClientAddress] ([IdClient],[IdAdress],[AdressData])
		SELECT  ClientID,AddressType,Address
		FROM @Address cr inner join [dbo].[Addresses] ad on cr.AddressType = ad.Type
		WHERE
		   NOT EXISTS (SELECT * FROM [dbo].[ClientAddress] c
					  WHERE cr.ClientID = c.[IdClient] and cr.AddressType = c.IdAdress )

select @flag
	
	end try
	begin catch
		throw;
	end catch

END
GO


----------------------------------procedure InsertClient--------------
IF EXISTS (SELECT type_desc, type FROM sys.procedures WITH(NOLOCK) WHERE NAME = 'InsertClient' AND type = 'P')
	DROP PROCEDURE [dbo].[InsertClient]
GO

CREATE PROCEDURE [dbo].[InsertClient]
(
	@p_ClientNumber int,
	@p_Name nvarchar(20),
	@p_BirthDay datetime,
	@p_AdressData nvarchar(20)
	
)
AS
BEGIN
	SET NOCOUNT ON;
	
	begin try
		
		if not exists (select * from dbo.Clients where ClientNumber = @p_ClientNumber)
		begin
			insert into [dbo].[Clients] ([ClientNumber],[Name],[BirthDay]) 
			values (@p_ClientNumber,@p_Name,@p_BirthDay);		

			insert into [dbo].[ClientAddress] ([IdClient],[IdAdress],[AdressData]) 
			values (@p_ClientNumber,1,@p_AdressData);		

		end
		select  @p_ClientNumber as result
	end try
		begin catch
			throw
		end catch

	
END
GO