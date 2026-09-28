<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <title>Basics 2: Logic - CF Learn</title>
</head>
<body>
    <p><a href="index.cfm">Back to 01 - Basics</a></p>
    <h1>2. Logic, loops and data</h1>

    <h2>Decisions with cfif</h2>
    <p>Comparisons use words: EQ, NEQ, GT, LT, GTE, LTE.</p>
    <pre>
&lt;cfset markah = 75&gt;
&lt;cfif markah GTE 80&gt;A
&lt;cfelseif markah GTE 60&gt;B
&lt;cfelse&gt;C&lt;/cfif&gt;
    </pre>
    <cfset markah = 75>
    <p><b>Output:</b>
        <cfif markah GTE 80>A<cfelseif markah GTE 60>B<cfelse>C</cfif>
    </p>

    <h2>Loops with cfloop</h2>
    <pre>
&lt;cfloop index="i" from="1" to="5"&gt;#i# &lt;/cfloop&gt;
    </pre>
    <p><b>Output:</b>
        <cfoutput><cfloop index="i" from="1" to="5">#i# </cfloop></cfoutput>
    </p>

    <h2>Arrays (start at index 1)</h2>
    <pre>
&lt;cfset kelas = ["Bestari","Cerdik","Amanah"]&gt;
&lt;cfoutput&gt;First: #kelas[1]#, total: #arrayLen(kelas)#&lt;/cfoutput&gt;
    </pre>
    <cfset kelas = ["Bestari","Cerdik","Amanah"]>
    <p><b>Output:</b>
        <cfoutput>First: #kelas[1]#, total: #arrayLen(kelas)#</cfoutput>
    </p>

    <h2>Structs (key/value - like one database row)</h2>
    <pre>
&lt;cfset pelajar = { name="Nur Aisyah", email="nur@example.com" }&gt;
&lt;cfoutput&gt;#pelajar.name# - #pelajar.email#&lt;/cfoutput&gt;
    </pre>
    <cfset pelajar = { name="Nur Aisyah", email="nur@example.com" }>
    <p><b>Output:</b>
        <cfoutput>#pelajar.name# - #pelajar.email#</cfoutput>
    </p>

    <p><i>A database query returns rows that behave much like these structs - that is the next page.</i></p>
    <p><a href="03-database.cfm">Next: Database</a></p>
</body>
</html>
