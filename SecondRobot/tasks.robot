*** Settings ***
Documentation       Orders robots from RobotSpareBin Industries Inc.
...                 Saves the order HTML receipt as a PDF file.
...                 Saves the screenshot of the ordered robot.
...                 Embeds the screenshot of the robot to the PDF receipt.
...                 Creates ZIP archive of the receipts and the images.

Library             RPA.Browser.Selenium    auto_close=${FALSE}
Library             RPA.HTTP
Library             RPA.Tables
Library             RPA.PDF
Library             RPA.Archive


*** Variables ***
${Out_FolderName1}=     Initialoutput
${Out_FolderName2}=     Finaloutput
${Delay}=               3


*** Tasks ***
Order robots from RobotSpareBin Industries Inc
    Open the robot order website
    ${orders}=    Get orders
    FOR    ${row}    IN    @{orders}
        Close the annoying modal
        Fill the form    ${row}
        Preview the robot
        Submit the order
        ${pdf}=    Store the receipt as a PDF file    ${row}
        ${screenshot}=    Take a screenshot of the robot    ${row}
        Embed the robot screenshot to the receipt PDF file    ${screenshot}    ${pdf}    ${row}
        Go to order another robot
    END
    Create a ZIP file of the receipts


*** Keywords ***
 Open the robot order website
    Open Available Browser    https://robotsparebinindustries.com/#/robot-order

Get orders
    Download    https://robotsparebinindustries.com/orders.csv    overwrite=True
    ${orders}=    Read table from CSV    orders.csv    header=True
    RETURN    ${orders}

Close the annoying modal
    Click Button    OK

Fill the form
    [Arguments]    ${row}
    Select From List By Value    head    ${row}[Head]
    Click Element    id:id-body-${row}[Body]
    Input Text    css:input[placeholder="Enter the part number for the legs"]    ${row}[Legs]
    Input Text    css:input[placeholder="Shipping address"]    ${row}[Address]

Preview the robot
    Click Button    preview
    Set Selenium Speed    ${Delay} seconds

Submit the order
    Wait Until Element Is Visible    id:robot-preview-image
    Click Button    xpath://*[@id="order"]
    Set Selenium Speed    ${Delay} seconds

Store the receipt as a PDF file
    [Arguments]    ${row}
    Wait Until Element Is Visible    id:receipt
    ${receipt_results_html}=    Get Element Attribute    id:receipt    outerHTML
    Html To Pdf    ${receipt_results_html}    ${OUTPUT_DIR}${/}${Out_FolderName1}${/}${row}[Order number].pdf
    RETURN    ${OUTPUT_DIR}${/}${Out_FolderName1}${/}${row}[Order number].pdf

Take a screenshot of the robot
    [Arguments]    ${row}
    Screenshot    id:robot-preview-image    ${OUTPUT_DIR}${/}${Out_FolderName1}${/}${row}[Order number].png
    RETURN    ${OUTPUT_DIR}${/}${Out_FolderName1}${/}${row}[Order number].png

Embed the robot screenshot to the receipt PDF file
    [Arguments]    ${screenshot}    ${pdf}    ${row}
    ${files}=    Create List
    ...    ${pdf}
    ...    ${screenshot}
    Add Files To PDF    ${files}    ${OUTPUT_DIR}${/}${Out_FolderName2}${/}${row}[Order number].pdf

Go to order another robot
    Click Button    order-another

Create a ZIP file of the receipts
    Archive Folder With Zip    ${OUTPUT_DIR}${/}${Out_FolderName2}    ${OUTPUT_DIR}${/}Final.zip
