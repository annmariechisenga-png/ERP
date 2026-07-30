import json

# Load the JSON data
with open('/Users/Work/Desktop/ERP/org-data/org_chart.json', 'r') as f:
    data = json.load(f)

# Check if Legal department exists
if 'Legal' not in data:
    print("Legal department not found")
    exit()

# Fix Town Council structure
if 'Town' in data['Legal']:
    town_data = data['Legal']['Town']
    
    # Create a proper hierarchy for Town Council
    # Level 1: Council Secretary (already exists as root)
    # Level 2: Council Advocate (LEG-ADV-TOWN)
    # Level 3: Senior Legal Assistant (LEG-SRASST-TOWN)
    # Level 4: Registry Clerk (LEG-REG-TOWN)
    
    # Create positions if they don't exist
    positions = {
        'LEG-ADV-TOWN': {
            'position_id': 'LEG-ADV-TOWN',
            'title': 'Council Advocate',
            'salary_scale': 'LGSS/05',
            'establishment': 1,
            'reports_to': 'COUNCIL-SECRETARY',
            'section': 'Legal Unit',
            'council_type': 'Town',
            'department': 'Legal',
            'direct_reports': []
        },
        'LEG-SRASST-TOWN': {
            'position_id': 'LEG-SRASST-TOWN',
            'title': 'Senior Legal Assistant',
            'salary_scale': 'LGSS/07',
            'establishment': 2,
            'reports_to': 'LEG-ADV-TOWN',
            'section': 'Legal Unit',
            'council_type': 'Town',
            'department': 'Legal',
            'direct_reports': []
        },
        'LEG-REG-TOWN': {
            'position_id': 'LEG-REG-TOWN',
            'title': 'Registry Clerk',
            'salary_scale': 'LGSS/17',
            'establishment': 1,
            'reports_to': 'LEG-SRASST-TOWN',
            'section': 'Legal Unit',
            'council_type': 'Town',
            'department': 'Legal',
            'direct_reports': []
        }
    }
    
    # Initialize all_positions if not exists
    if 'all_positions' not in town_data:
        town_data['all_positions'] = {}
    
    # Add positions
    for pos_id, pos in positions.items():
        if pos_id not in town_data['all_positions']:
            town_data['all_positions'][pos_id] = pos
            print(f"  ✅ Added: {pos['title']} ({pos_id})")
    
    # Build proper hierarchy
    # Find or create root positions
    if 'root_positions' not in town_data or not town_data['root_positions']:
        town_data['root_positions'] = []
    
    # Check if Council Advocate is already in root_positions
    council_advocate_exists = False
    for root in town_data['root_positions']:
        if root.get('position_id') == 'LEG-ADV-TOWN':
            council_advocate_exists = True
            break
    
    if not council_advocate_exists:
        # Add Council Advocate as root (reports to Council Secretary)
        town_data['root_positions'].append(positions['LEG-ADV-TOWN'])
        print("  ✅ Added Council Advocate to root positions")
    
    # Build relationships
    # Council Advocate -> Senior Legal Assistant
    for root in town_data['root_positions']:
        if root.get('position_id') == 'LEG-ADV-TOWN':
            if 'direct_reports' not in root:
                root['direct_reports'] = []
            # Check if Senior Legal Assistant is already a direct report
            if not any(r.get('position_id') == 'LEG-SRASST-TOWN' for r in root['direct_reports']):
                root['direct_reports'].append(positions['LEG-SRASST-TOWN'])
                print("  ✅ Added Senior Legal Assistant as direct report to Council Advocate")
    
    # Senior Legal Assistant -> Registry Clerk
    for root in town_data['root_positions']:
        if root.get('position_id') == 'LEG-ADV-TOWN':
            for child in root.get('direct_reports', []):
                if child.get('position_id') == 'LEG-SRASST-TOWN':
                    if 'direct_reports' not in child:
                        child['direct_reports'] = []
                    if not any(g.get('position_id') == 'LEG-REG-TOWN' for g in child['direct_reports']):
                        child['direct_reports'].append(positions['LEG-REG-TOWN'])
                        print("  ✅ Added Registry Clerk as direct report to Senior Legal Assistant")
    
    # Update total positions count
    total_count = len(town_data.get('all_positions', {}))
    town_data['total_positions'] = total_count
    print(f"\n  📊 Town Council total positions: {total_count}")

# Save the updated JSON
with open('/Users/Work/Desktop/ERP/org-data/org_chart.json', 'w') as f:
    json.dump(data, f, indent=2)

print("\n✅ Legal department fixed! Registry Clerk has been added.")
print("   Refresh your browser to see the updated org chart.")
