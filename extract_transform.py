import pandas as pd
import os


def defineDataBatch():
    filename = "./data/Food_Inspections.csv"
    df = pd.read_csv(filename, low_memory=False)
    header = pd.read_csv(filename, nrows=1, header=None).values.tolist()[0]

    n = len(df) - 250000
    data = pd.read_csv(filename, nrows=250000)
    data.to_csv('./data/stageFoodInspectionData.csv', index=False)

    print(len(data))

    # progressive_data = pd.read_csv(
    #     "./data/Food_Inspections.csv", skiprows=lambda x: x < len(df) - n+1, header=None, names=header, low_memory=False)

    progressive_data = pd.read_csv(
        "./data/Food_Inspections.csv", skiprows=range(1, len(data)+2), header=0, low_memory=False)

    print(len(progressive_data))

    progressive_data.to_csv(
        './data/progressiveFoodInspectionData.csv', index=False)


def extractTransformFoodData(fileName):

    df = pd.read_csv(fileName, low_memory=False)

    # transform
    df['Violations'] = df['Violations'].fillna('NIL')
    df = df.rename(columns={'License #': 'LicenseId'})
    df = df.rename(columns={'Inspection Date': 'InspectionDate'})
    df = df.rename(columns={'Inspection Type': 'InspectionType'})
    df = df.rename(columns={'DBA Name': 'DBA_Name'})
    df = df.rename(columns={'AKA Name': 'AKA_Name'})
    df = df.rename(columns={'Facility Type': 'FacilityType'})
    df = df.rename(columns={'Inspection ID': 'InspectionID'})
    df.dropna(subset=['LicenseId'], inplace=True)
    df['AKA_Name'] = df['AKA_Name'].fillna('NIL')
    df['LicenseId'] = df['LicenseId'].fillna('0')
    df['FacilityType'] = df['FacilityType'].fillna('NIL')
    df['Risk'] = df['Risk'].fillna('NIL')
    df['InspectionType'] = df['InspectionType'].fillna('NIL')
    df['LicenseId'] = df['LicenseId'].astype('int')
    # filling null city with chicago
    df['City'] = df['City'].fillna('CHICAGO')
    # filling state as IL
    df['State'] = df['State'].fillna('IL')

    # remove rows with no zipcodes
    df = df[df['Zip'].notna()]

    df = df[df['Latitude'].notna()]

    df.InspectionDate = pd.to_datetime(df.InspectionDate)
    print(df.head(0))
    df.to_csv(fileName, index=False)


def extractTransformLicenseData():

    df = pd.read_csv('./data/Business_Licenses.csv', low_memory=False)
    # filling null city with chicago
    df['CITY'] = df['CITY'].fillna('CHICAGO')
    # filling state as IL
    df['STATE'] = df['CITY'].fillna('IL')
    df['LATITUDE'] = df['LATITUDE'].fillna(0)
    df['LONGITUDE'] = df['LONGITUDE'].fillna(0)
    df['LOCATION'] = df['LOCATION'].fillna(0)
    df['LICENSE NUMBER'] = df['LICENSE NUMBER'].fillna(0)
    df['BUSINESS ACTIVITY ID'] = df['BUSINESS ACTIVITY ID'].fillna(0)
    df['LICENSE STATUS CHANGE DATE'] = df['LICENSE STATUS CHANGE DATE'].fillna(
        "09/09/2045")
    df['LICENSE APPROVED FOR ISSUANCE'] = df['LICENSE APPROVED FOR ISSUANCE'].fillna(
        "09/09/2045")
    df['LICENSE TERM EXPIRATION DATE'] = df['LICENSE TERM EXPIRATION DATE'].fillna(
        "09/09/2045")
    df['PAYMENT DATE'] = df['PAYMENT DATE'].fillna("09/09/2045")
    df['APPLICATION REQUIREMENTS COMPLETE'] = df['APPLICATION REQUIREMENTS COMPLETE'].fillna(
        "09/09/2045")
    df['APPLICATION CREATED DATE'] = df['APPLICATION CREATED DATE'].fillna(
        "09/09/2045")
    df.fillna(0)
    df = df.fillna(0)

    df.to_csv('./data/stageBusiness_Licenses.csv', index=False)
    transformMissingValues()


def transformMissingValues():
    df1 = pd.read_csv('./data/stageFoodInspectionData.csv', low_memory=False)
    df2 = pd.read_csv('./data/stageBusiness_Licenses.csv', low_memory=False)

    # check if values of column A in df1 are missing in column A of df2
    missing_values = df1[~df1['LicenseId'].isin(df2['LICENSE ID'])]

    # print the missing values
    # print(missing_values['LicenseId'])

    for index, row in missing_values.iterrows():
        df1['LicenseId'] = df1['LicenseId'].replace(row['LicenseId'], -1)

    df1.to_csv('./data/stageFoodInspectionDataFinal.csv', index=False)


def transformMissingValuesInDeltas():
    df1 = pd.read_csv(
        './data/progressiveFoodInspectionData.csv', low_memory=False)
    df2 = pd.read_csv('./data/stageBusiness_Licenses.csv', low_memory=False)

    # check if values of column A in df1 are missing in column A of df2
    missing_values = df1[~df1['LicenseId'].isin(df2['LICENSE ID'])]

    # print the missing values
    # print(missing_values['LicenseId'])

    for index, row in missing_values.iterrows():
        df1['LicenseId'] = df1['LicenseId'].replace(row['LicenseId'], -1)

    df1.to_csv('./data/progressiveFoodInspectionData.csv', index=False)


defineDataBatch()


extractTransformFoodData('./data/stageFoodInspectionData.csv')

extractTransformLicenseData()

transformMissingValues()


# progressive data transformation
extractTransformFoodData('./data/progressiveFoodInspectionData.csv')
transformMissingValuesInDeltas()
