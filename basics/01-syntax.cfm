<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <title>Basics 1: Syntax - CF Learn</title>
</head>
<body>
    <p><a href="index.cfm">Back to 01 - Basics</a></p>
    <h1>1. Variables and output</h1>

    <h2>Create a variable with cfset</h2>
    <p>Nothing is shown on screen - it just stores a value.</p>
    <pre>
&lt;cfset name = "Ahmad Danish"&gt;
&lt;cfset age  = 17&gt;
    </pre>

    <h2>Show a variable with cfoutput</h2>
    <p>Inside <code>&lt;cfoutput&gt;</code>, text between <code>#</code> hashes is treated as a variable.</p>
    <pre>
&lt;cfoutput&gt;Name: #name#, Age: #age#&lt;/cfoutput&gt;
    </pre>

    <cfset name = "Ahmad Danish">
    <cfset age  = 17>
    <p><b>Output:</b>
        <cfoutput>Name: #name#, Age: #age#</cfoutput>
    </p>
    <p><i>Note: forget cfoutput and #name# prints literally as the text "#name#".</i></p>

    <h2>Expressions and functions</h2>
    <pre>
&lt;cfoutput&gt;Uppercase: #ucase(name)#, Next year: #age + 1#&lt;/cfoutput&gt;
    </pre>
    <p><b>Output:</b>
        <cfoutput>Uppercase: #ucase(name)#, Next year: #age + 1#</cfoutput>
    </p>

    <h2>Data types</h2>
    <pre>
&lt;cfset price   = 9.90&gt;
&lt;cfset active  = true&gt;
&lt;cfset today   = now()&gt;
    </pre>
    <cfset price  = 9.90>
    <cfset active = true>
    <cfset today  = now()>
    <p><b>Output:</b>
        <cfoutput>
            Price: RM #numberFormat(price, "9.00")# |
            Active? #yesNoFormat(active)# |
            Today: #dateFormat(today, "dd mmm yyyy")#
        </cfoutput>
    </p>

    <h2>Comments</h2>
    <p>CFML comments use three dashes and never reach the browser:</p>
    <pre>
&lt;!--- the visitor never sees this line ---&gt;
    </pre>

    <p><a href="02-logic.cfm">Next: Logic</a></p>
</body>
</html>
