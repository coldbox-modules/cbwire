<!--- Test page to demonstrate the new lazy flag feature --->
<cfoutput>
    <h1>CBWIRE Lazy Flag Feature Demo</h1>
    <p>This page demonstrates the new <code>lazy = true</code> flag for CBWIRE components.</p>
    
    <h2>Test 1: Component with lazy = true (should be lazy loaded)</h2>
    <div style="border: 1px solid #ccc; padding: 10px; margin: 10px 0;">
        #wire( name="TestAlwaysLazyComponent" )#
    </div>
    
    <h2>Test 2: Same component with explicit lazy=false (should render immediately)</h2>  
    <div style="border: 1px solid #ccc; padding: 10px; margin: 10px 0;">
        #wire( name="TestAlwaysLazyComponent", lazy=false )#
    </div>
    
    <h2>Test 3: Parent with lazy child component</h2>
    <div style="border: 1px solid #ccc; padding: 10px; margin: 10px 0;">
        #wire( name="TestParentWithLazyChild" )#
    </div>
    
    <h2>Test 4: Parent overriding child's lazy setting</h2>
    <div style="border: 1px solid #ccc; padding: 10px; margin: 10px 0;">
        #wire( name="TestParentWithOverride" )#
    </div>
</cfoutput>

<script>
    document.addEventListener('DOMContentLoaded', function() {
        console.log('=== CBWIRE Lazy Flag Feature Demo ===');
        console.log('Test 1: Should show lazy loading placeholder with x-intersect');
        console.log('Test 2: Should show actual component content immediately'); 
        console.log('Test 3: Parent should show normally, child should be lazy');
        console.log('Test 4: Both parent and child should show immediately');
    });
</script>