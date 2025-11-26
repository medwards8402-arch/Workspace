class Plant {
  final String name;
  final String code;
  final String icon; // Emoji/icon placeholder
  final String color; // Hex color string
  final String type;
  final int plantAfterFrostDays;
  final int startIndoorsWeeks;
  final int harvestWeeks;
  final int sqftSpacing;
  final int? cellsRequired;
  final String lightLevel; // 'low' | 'high'
  final List<String> tips;
  final bool supportsFall;
  final int fallPlantBeforeFrostDays;
  final int fallStartIndoorsWeeks;
  final String careInstructions;
  final List<String> varieties;
  final String watering;
  final String soil;
  final String companions;

  const Plant({
    required this.name,
    required this.code,
    required this.icon,
    required this.color,
    required this.type,
    required this.plantAfterFrostDays,
    required this.startIndoorsWeeks,
    required this.harvestWeeks,
    required this.sqftSpacing,
    this.cellsRequired,
    required this.lightLevel,
    this.tips = const [],
    this.supportsFall = false,
    this.fallPlantBeforeFrostDays = 0,
    this.fallStartIndoorsWeeks = 0,
    this.careInstructions = '',
    this.varieties = const [],
    this.watering = '',
    this.soil = '',
    this.companions = '',
  });
}

class UsdaZone {
  final int month; // Avg last spring frost month
  final int day; // Avg last spring frost day
  final int? firstMonth; // Avg first fall frost month
  final int? firstDay; // Avg first fall frost day
  const UsdaZone({
    required this.month,
    required this.day,
    this.firstMonth,
    this.firstDay,
  });
}

const Map<String, UsdaZone> usdaZones = {
  '3a': UsdaZone(month: 5, day: 25, firstMonth: 9, firstDay: 8),
  '3b': UsdaZone(month: 5, day: 20, firstMonth: 9, firstDay: 15),
  '4a': UsdaZone(month: 5, day: 15, firstMonth: 9, firstDay: 21),
  '4b': UsdaZone(month: 5, day: 10, firstMonth: 9, firstDay: 28),
  '5a': UsdaZone(month: 5, day: 5, firstMonth: 10, firstDay: 10),
  '5b': UsdaZone(month: 4, day: 30, firstMonth: 10, firstDay: 15),
  '6a': UsdaZone(month: 4, day: 20, firstMonth: 10, firstDay: 25),
  '6b': UsdaZone(month: 4, day: 15, firstMonth: 10, firstDay: 30),
  '7a': UsdaZone(month: 4, day: 5, firstMonth: 11, firstDay: 10),
  '7b': UsdaZone(month: 3, day: 30, firstMonth: 11, firstDay: 20),
  '8a': UsdaZone(month: 3, day: 20, firstMonth: 11, firstDay: 30),
  '8b': UsdaZone(month: 3, day: 10, firstMonth: 12, firstDay: 10),
  '9a': UsdaZone(month: 2, day: 25, firstMonth: 12, firstDay: 20),
  '9b': UsdaZone(month: 2, day: 15, firstMonth: 12, firstDay: 31),
  '10a': UsdaZone(month: 1, day: 31),
  '10b': UsdaZone(month: 1, day: 20),
};

const List<Plant> plants = [
  Plant(name: 'Arugula', code: 'ARU', icon: '🥬', color: '#84cc16', type: 'vegetable', plantAfterFrostDays: -21, startIndoorsWeeks: 0, harvestWeeks: 5, sqftSpacing: 4, lightLevel: 'low', supportsFall: true, fallPlantBeforeFrostDays: 28, fallStartIndoorsWeeks: 0,
    careInstructions: 'Fast-growing cool-season green that is ready to harvest in just 3-5 weeks. Sow seeds every 2-3 weeks for continuous harvest. Cut outer leaves when 2-3 inches long, letting center continue growing. Bolts quickly in heat, so best grown spring and fall.',
    watering: 'Keep soil consistently moist to prevent bolting and bitter flavor. Water lightly and frequently, about 1 inch per week.',
    soil: 'Prefers rich, well-draining soil with pH 6.0-7.0. Mix in compost before planting. Benefits from light nitrogen fertilization.',
    companions: 'Grows well with carrots, lettuce, and other cool-season greens. Plant near taller crops for afternoon shade in warm weather.',
    varieties: [
      'Standard Arugula: Classic spicy, peppery flavor with deeply lobed leaves. Fast maturing (40 days) and productive. Best for spring and fall, bolts quickly in heat.',
      'Wild Arugula (Sylvetta): Slow-growing perennial type with smaller, more deeply cut leaves and intense peppery flavor. Takes 50 days but less prone to bolting, can harvest for months.',
      'Astro: Mild, less peppery variety good for kids. Large smooth leaves, very fast growing (30 days). More heat tolerant than standard types.',
      'Wasabi Arugula: Serrated leaves with strong wasabi-like heat. Grows quickly like standard but with more intense flavor for those who love spice.'
    ]),
  Plant(name: 'Artichoke', code: 'ART', icon: '🌿', color: '#6b7280', type: 'vegetable', plantAfterFrostDays: -7, startIndoorsWeeks: 8, harvestWeeks: 52, sqftSpacing: 1, cellsRequired: 4, lightLevel: 'high', tips: ['Perennial in zones 7+; treat as annual', 'Harvest before flowers fully open'],
    careInstructions: 'Perennial in mild climates (zones 7-11), grown as annual elsewhere. Large plants (3-4 feet) needing space. Harvest flower buds before opening. Cut main bud first for larger side shoots. Needs vernalization (cold period) to produce buds. In cold climates, heavily mulch or dig up and store roots.',
    watering: 'Heavy water needs, 1-2 inches per week. Consistent moisture for tender buds.',
    soil: 'Rich, well-draining soil with pH 6.5-7.5. Heavy feeder. Add lots of compost.',
    companions: 'Plant with tarragon and peas. Takes up significant space.',
    varieties: [
      'Green Globe: Most common variety with large (3-5 inch) green buds. Reliable for annual production. 85-100 days from transplant. Adapts to various climates.'
    ]),
  Plant(name: 'Asparagus', code: 'ASP', icon: '🌿', color: '#059669', type: 'vegetable', plantAfterFrostDays: -14, startIndoorsWeeks: 0, harvestWeeks: 104, sqftSpacing: 1, cellsRequired: 4, lightLevel: 'high', tips: ['Perennial; avoid harvesting first 2–3 years', 'Deep roots; dedicate bed'],
    careInstructions: 'Long-lived perennial (15-30 years) requiring patience. Plant 1-year crowns in trenches. No harvest first year, light harvest year 2, full harvest year 3+. Harvest spears when 6-8 inches tall for 6-8 weeks in spring. Stop when spears thin. Let ferns grow in summer to feed crowns.',
    watering: 'Deep watering during growth. Provide 1-2 inches per week. Established plants drought-tolerant but produce better with water.',
    soil: 'Well-draining soil with pH 6.5-7.5. Deep preparation (12+ inches). Add compost annually.',
    companions: 'Plant with tomatoes, parsley, and basil. Avoid onions and garlic.',
    varieties: [
      'Jersey Knight: All-male hybrid producing thick spears. Disease resistant. Very cold-hardy (zone 3).',
      'Purple Passion: Purple spears sweeter and more tender than green. Turns green when cooked. Cold-hardy to zone 4.'
    ]),
  Plant(name: 'Basil', code: 'BAS', icon: '🌿', color: '#22c55e', type: 'herb', plantAfterFrostDays: 14, startIndoorsWeeks: 6, harvestWeeks: 10, sqftSpacing: 2, lightLevel: 'high',
    careInstructions: 'Pinch off flower buds to encourage bushy growth and prolong harvest. Harvest regularly by cutting stems just above a leaf pair. Basil is sensitive to cold - bring containers inside before frost.',
    watering: 'Water regularly, keeping soil moist but not soggy. Basil is susceptible to root rot in waterlogged soil. Water at base to keep leaves dry.',
    soil: 'Rich, well-draining soil with pH 6.0-7.0. Feed with balanced fertilizer every 2-3 weeks for continuous production.',
    companions: 'Excellent companion for tomatoes and peppers. Repels aphids and other pests. Also grows well with oregano.',
    varieties: [
      'Sweet Italian Basil: Classic pesto and Italian cooking varieties. Genovese has intense, slightly spicy flavor with large leaves, the gold standard for pesto. Large Leaf grows bigger leaves (3-4 inches) for easy harvesting, milder flavor good for wraps and fresh eating.',
      'Specialty Flavored Basil: Each has distinct culinary uses. Thai basil has licorice-anise flavor with purple stems, essential for authentic Asian dishes and holds up to heat. Lemon basil has bright citrus notes perfect for fish and tea. Cinnamon basil has spicy-sweet flavor with pink flowers.',
      'Purple Ornamental Basil: Beautiful and edible. Dark Opal has deep purple leaves with slightly milder flavor than green basil, makes stunning purple vinegar. Red Rubin is improved Dark Opal with darker color and more uniform growth, excellent as ornamental border plant.',
      'Compact Basil: Ideal for containers and small spaces. Spicy Globe forms tight 8-10 inch mounds of tiny leaves with concentrated flavor, no pinching needed. Pesto Perpetuo is variegated green-white with excellent flavor, grows as perennial in mild climates.'
    ]),
  Plant(name: 'Beans', code: 'BNB', icon: '🫘', color: '#047857', type: 'vegetable', plantAfterFrostDays: 10, startIndoorsWeeks: 0, harvestWeeks: 8, sqftSpacing: 6, lightLevel: 'high',
    careInstructions: 'Bush beans are compact and easy to grow. Pole beans need support but produce longer. Pick beans regularly to encourage more production. Avoid touching plants when wet to prevent disease spread.',
    watering: 'Water regularly, about 1 inch per week. Increase watering when flowers appear and pods develop. Avoid overhead watering which can spread diseases.',
    soil: 'Well-draining soil with pH 6.0-7.0. Beans fix nitrogen, so avoid high-nitrogen fertilizer. Add compost before planting.',
    companions: 'Plant with corn, cucumbers, and squash (Three Sisters method). Avoid planting near onions or garlic.',
    varieties: [
      'Bush Green Beans: Compact plants need no support, all beans ripen in 2-week window. Blue Lake Bush produces classic round green beans with excellent flavor, stringless and tender. Provider is extra early (50 days) and sets pods in cool weather, good for short seasons and succession planting.',
      'Pole Green Beans: Require trellis but produce for 6-8 weeks. Kentucky Wonder is the classic heirloom with 9-inch curved pods and rich flavor, very vigorous climber to 6+ feet. Fortex is a French filet type with extra-long (11 inch) slender pods that stay tender even when large.',
      'Yellow Wax Beans: Bright yellow color, milder flavor than green. Golden Wax is a bush type with 5-6 inch pods, very productive with buttery texture. Pencil Pod is thin and round with exceptional tenderness, perfect for kids to pick, excellent fresh or canned.',
      'Specialty Beans: Unique colors and shapes. Purple Pod has stunning purple color (turns green when cooked), easy to spot for harvesting, bush or pole available. Romano (Italian Flat) has wide flat pods with intense beany flavor, meaty texture holds up well in cooking.'
    ]),
  Plant(name: 'Beet', code: 'BET', icon: '🟣', color: '#be123c', type: 'vegetable', plantAfterFrostDays: -21, startIndoorsWeeks: 0, harvestWeeks: 9, sqftSpacing: 9, lightLevel: 'low', supportsFall: true, fallPlantBeforeFrostDays: 56, fallStartIndoorsWeeks: 0,
    careInstructions: 'Beets are a dual-purpose crop with edible roots and greens. Thin seedlings to 3-4 inches apart, using thinnings in salads. Harvest when roots are 1.5-3 inches for best tenderness. Both roots and greens are highly nutritious.',
    watering: 'Water consistently to prevent woody, tough roots. Provide 1 inch per week. Mulch to maintain even moisture and prevent soil cracking.',
    soil: 'Prefers loose, well-draining soil free of rocks. pH 6.0-7.0. Add compost but avoid fresh manure which causes forking. Beets need boron; add kelp meal if deficient.',
    companions: 'Plant with onions, lettuce, and brassicas. Avoid pole beans which can stunt growth.',
    varieties: [
      'Detroit Dark Red: Classic deep red beet with sweet flavor. Reliable and uniform 2-3 inch round roots. Excellent for storage, canning, and fresh eating. Ready in 55-60 days.',
      'Golden Beet: Yellow-orange flesh that does not bleed, making it great for salads. Milder, sweeter flavor than red beets. Same growing requirements as red varieties.',
      'Chioggia (Candy Stripe): Italian heirloom with red and white concentric rings inside. Mild and sweet. Best eaten raw as rings fade when cooked. Beautiful presentation.',
      'Cylindra: Long cylindrical shape (6-8 inches) rather than round. More uniform slices, great for pickling and canning. Same flavor as round types but easier to process.'
    ]),
  Plant(name: 'Bok Choy', code: 'BOK', icon: '🥬', color: '#86efac', type: 'vegetable', plantAfterFrostDays: -14, startIndoorsWeeks: 0, harvestWeeks: 7, sqftSpacing: 4, lightLevel: 'low', supportsFall: true, fallPlantBeforeFrostDays: 42, fallStartIndoorsWeeks: 0, tips: ['Harvest before bolting'],
    careInstructions: 'Fast-growing Asian green with crunchy white stems and tender green leaves. Cool-season crop that bolts quickly in hot weather. Best grown in spring and fall. Harvest whole plant by cutting at soil level when 6-10 inches tall.',
    watering: 'Keep consistently moist, about 1-1.5 inches per week. Water stress causes premature bolting. Water at soil level to prevent disease.',
    soil: 'Rich, well-draining soil with plenty of compost. pH 6.0-7.5. Feed with nitrogen-rich fertilizer for rapid leaf growth.',
    companions: 'Plant with beets, onions, and herbs. Benefits from being near taller plants that provide afternoon shade.',
    varieties: [
      'Joi Choi: Most popular variety with thick white stems and dark green leaves. Upright habit, 10-12 inches tall. Slow to bolt, good heat tolerance for a bok choy (45-50 days).',
      'Baby Bok Choy: Miniature version harvested at 4-6 inches tall in just 30-35 days. Tender and mild. Perfect for stir-fries whole. Plant closer together (6-8 per sq ft).',
      'Red Choi: Burgundy-purple stems with green leaves. Same flavor as white-stemmed types but adds beautiful color. Slightly slower growing (50 days) but worth the wait.',
      'Toy Choy: Another mini variety, very uniform and fast (30 days). Spoon-shaped leaves. Excellent for succession planting and containers.'
    ]),
  Plant(name: 'Broccoli', code: 'BRC', icon: '🥦', color: '#166534', type: 'vegetable', plantAfterFrostDays: -14, startIndoorsWeeks: 6, harvestWeeks: 9, sqftSpacing: 1, cellsRequired: 2, lightLevel: 'high', supportsFall: true, fallPlantBeforeFrostDays: 70, fallStartIndoorsWeeks: 6,
    careInstructions: 'Harvest main head when tight and firm, before flowers open. After cutting main head, plant produces smaller side shoots for weeks. Cool-season crop that performs best in spring and fall. Light frost improves flavor.',
    watering: 'Consistent moisture is critical. Provide 1-1.5 inches per week. Water deeply to encourage strong roots. Mulch to retain moisture.',
    soil: 'Rich, well-draining soil with pH 6.0-7.0. Heavy feeder needing lots of compost. Side-dress with nitrogen fertilizer at transplant and when heads begin forming.',
    companions: 'Plant with onions, herbs, and beets. Avoid tomatoes, peppers, and strawberries.',
    varieties: [
      'Calabrese: Fast-maturing Italian heirloom (55-60 days). Medium-large central head followed by many side shoots. Classic broccoli flavor. Good for succession planting.',
      'Belstar: Heat-tolerant hybrid with large dome-shaped heads. Better bolt resistance for extended spring harvest. Fewer side shoots but larger main head. 66 days.',
      'DeCicco: Heirloom bred for side shoot production rather than large main head. Harvest for months. Excellent for small gardens wanting continuous harvest. 48 days.',
      'Purple Sprouting: Overwintered variety producing purple spears in early spring. Plant in late summer, harvest following March-May. Sweeter flavor than green broccoli.'
    ]),
  Plant(name: 'Brussels Sprouts', code: 'BRS', icon: '🥦', color: '#14532d', type: 'vegetable', plantAfterFrostDays: -7, startIndoorsWeeks: 6, harvestWeeks: 16, sqftSpacing: 1, cellsRequired: 2, lightLevel: 'high',
    careInstructions: 'Long-season crop (90-120 days) best planted for fall harvest. Frost dramatically improves flavor by converting starches to sugars. Harvest from bottom up when sprouts are 1-1.5 inches. Remove lower leaves as you harvest. Top plant to concentrate energy into remaining sprouts.',
    watering: 'Steady, consistent watering. Provide 1-1.5 inches per week. Deep watering encourages strong stalks to support heavy sprouts.',
    soil: 'Rich, firm soil with pH 6.0-7.5. Very heavy feeder needing lots of nitrogen. Firm soil helps support tall plants. Side-dress monthly with compost or fertilizer.',
    companions: 'Plant with onions, potatoes, and herbs. Avoid strawberries and tomatoes.',
    varieties: [
      'Long Island Improved: Classic heirloom variety with excellent cold hardiness. Produces 50-100 sprouts per plant. Traditional flavor, better after hard frost. 90-100 days.',
      'Jade Cross: Hybrid with compact plants and uniform sprouts. More heat tolerant and disease resistant than heirlooms. Milder flavor. Good for beginners. 85-95 days.',
      'Rubine Red: Purple-red sprouts that hold color when cooked. Sweeter, nuttier flavor than green varieties. Beautiful in the garden and on the plate. 95-105 days.',
      'Nautic: Fast-growing hybrid producing sprouts in just 80 days. Shorter plants (18 inches) good for small spaces. Excellent flavor without needing heavy frost.'
    ]),
  Plant(name: 'Cabbage', code: 'CAB', icon: '🥬', color: '#94a3b8', type: 'vegetable', plantAfterFrostDays: -21, startIndoorsWeeks: 6, harvestWeeks: 11, sqftSpacing: 1, cellsRequired: 2, lightLevel: 'low', supportsFall: true, fallPlantBeforeFrostDays: 70, fallStartIndoorsWeeks: 6,
    careInstructions: 'Harvest when heads feel solid and firm. Cut heads leaving outer leaves and stump; may produce small secondary heads. Prevent splitting by twisting head 90 degrees to break some roots after maturing. Cool-season crop excellent for spring and fall.',
    watering: 'Consistent moisture prevents splitting and bitterness. Provide 1-1.5 inches per week. Avoid heavy watering as heads mature to prevent splitting.',
    soil: 'Rich, well-draining soil with pH 6.0-6.8. Heavy feeder needing lots of nitrogen. Add compost and side-dress with fertilizer when heads begin forming.',
    companions: 'Plant with onions, potatoes, and celery. Avoid tomatoes, peppers, and strawberries.',
    varieties: [
      'Early Jersey Wakefield: Fast-maturing heirloom (60-70 days) with small conical heads (2-3 lbs). Good for small gardens and succession planting. Classic coleslaw type.',
      'Copenhagen Market: Round heads weighing 3-4 lbs. Reliable and uniform. Good for fresh eating and sauerkraut. 70-75 days. Stores moderately well.',
      'Red Acre: Compact red cabbage with 3-4 lb heads. Beautiful purple-red color, great for coleslaw. Higher in antioxidants than green types. 70-76 days.',
      'Late Flat Dutch: Large storage cabbage (10-15 lbs) maturing in 100+ days. Plant in summer for fall harvest. Excellent keeper, storing 3-5 months in cool conditions.'
    ]),
  Plant(name: 'Carrot', code: 'CAR', icon: '🥕', color: '#fb923c', type: 'vegetable', plantAfterFrostDays: -21, startIndoorsWeeks: 0, harvestWeeks: 9, sqftSpacing: 16, lightLevel: 'low', supportsFall: true, fallPlantBeforeFrostDays: 70, fallStartIndoorsWeeks: 0,
    careInstructions: 'Carrots need loose, rock-free soil for straight roots. Thin seedlings to proper spacing once they are 2 inches tall. Keep soil moist until germination (10-14 days). A light frost improves sweetness.',
    watering: 'Keep soil consistently moist during germination. Once established, water deeply once a week. Mulch to prevent soil from drying and cracking.',
    soil: 'Deep, loose, sandy loam free of rocks and clumps. pH 6.0-6.8. Avoid fresh manure which causes forked roots. Add compost several weeks before planting.',
    companions: 'Companion plant with onions, leeks, rosemary, and sage. Avoid dill which can cross-pollinate.',
    varieties: [
      'Standard Long Carrots: Classic 7-8 inch roots need deep, loose soil. Danvers is a reliable heirloom with broad shoulders, stores well for winter. Nantes-type has cylindrical shape with rounded tip, sweeter and more tender than Danvers, excellent for fresh eating and juicing.',
      'Short Stocky Carrots: Only 4-5 inches long, work in heavy or shallow soils. Chantenay has broad shoulders tapering to point, very sweet and stores exceptionally well. Oxheart is almost round with large diameter, grows in clay soil where others fail, great for chunky cuts.',
      'Baby/Mini Carrots: Harvest at 3-4 inches for true baby carrots (not cut-down regular carrots). Little Finger is slender and sweet, perfect for containers. Thumbelina is round like a radish, matures quickly (60 days), ideal for succession planting and kids gardens.',
      'Colored Varieties: All the nutrition plus visual appeal. Purple Dragon has purple skin and orange core, sweet and crunchy with anthocyanin antioxidants. Atomic Red is red throughout, lycopene-rich, and becomes redder when cooked, great for roasting.'
    ]),
  Plant(name: 'Cauliflower', code: 'CAF', icon: '🥦', color: '#6b7280', type: 'vegetable', plantAfterFrostDays: -14, startIndoorsWeeks: 6, harvestWeeks: 9, sqftSpacing: 1, cellsRequired: 2, lightLevel: 'high', supportsFall: true, fallPlantBeforeFrostDays: 75, fallStartIndoorsWeeks: 6,
    careInstructions: 'Most challenging brassica, sensitive to temperature and moisture stress. Blanch white varieties by tying outer leaves over developing head to keep it white. Harvest when head is tight and compact before curds separate. Fall crops often more successful than spring.',
    watering: 'Extremely important to maintain consistent moisture. Any stress causes buttoning (tiny heads) or bitterness. Provide 1-2 inches per week.',
    soil: 'Rich, moisture-retentive soil with pH 6.0-7.0. Very heavy feeder. Add lots of compost and side-dress every 2-3 weeks with fertilizer.',
    companions: 'Plant with onions, celery, and herbs. Avoid strawberries and tomatoes.',
    varieties: [
      'Snowball: Classic white cauliflower, fast maturing (50-60 days). 6-8 inch heads. Requires blanching. Good for beginners due to shorter season reducing risk of problems.',
      'Cheddar: Brilliant orange colored heads from high beta-carotene. No blanching needed. Sweeter, milder than white types. Color intensifies when cooked. 58-68 days.',
      'Purple of Sicily: Beautiful purple heads turn green when cooked but retain more antioxidants. Nutty, slightly sweeter flavor. Self-blanching (leaves naturally cover head). 70-85 days.',
      'Romanesco: Chartreuse fractal-patterned heads. Nuttier, more complex flavor than standard cauliflower. Easier to grow than white types. Stunning presentation. 75-85 days.'
    ]),
  Plant(name: 'Celery', code: 'CEL', icon: '🥬', color: '#84cc16', type: 'vegetable', plantAfterFrostDays: -7, startIndoorsWeeks: 10, harvestWeeks: 16, sqftSpacing: 2, lightLevel: 'high', tips: ['Long season; keep moist', 'Start indoors early'],
    careInstructions: 'Challenging crop with long season (100-130 days) and high water needs. Start indoors 10-12 weeks early. Transplant after frost. Needs consistent cool temperatures and moisture. Hill soil or wrap stems to blanch. Harvest whole plant or cut outer stalks. Can tolerate light frost.',
    watering: 'Heavy water needs - must never dry out. Provide 1-2 inches per week. Mulch heavily to retain moisture.',
    soil: 'Rich, moisture-retentive soil with pH 6.0-7.0. Heavy feeder. Add lots of compost and side-dress monthly.',
    companions: 'Plant with beans, tomatoes, and brassicas. Avoid carrots and parsnips.',
    varieties: [
      'Tango: Dark green, compact stalks with good flavor. More bolt-resistant. 85-100 days. Good for home gardens.',
      'Utah: Tall variety with thick, crisp stalks. Traditional grocery store type. 100-130 days. Good storage variety.'
    ]),
  Plant(name: 'Chives', code: 'CHV', icon: '🌿', color: '#4ade80', type: 'herb', plantAfterFrostDays: -14, startIndoorsWeeks: 0, harvestWeeks: 52, sqftSpacing: 16, lightLevel: 'high',
    careInstructions: 'Hardy perennial herb (zone 3-9) growing in grass-like clumps. Harvest by cutting stems near base with scissors. Both leaves and edible purple flowers have mild onion flavor. Divide clumps every 3-4 years to maintain vigor. Dies back in winter, returns in spring.',
    watering: 'Regular water for tender leaves. Provide 1 inch per week.',
    soil: 'Rich, well-draining soil with pH 6.0-7.0. Add compost annually.',
    companions: 'Plant with carrots, tomatoes, and roses. Repels aphids and Japanese beetles.',
    varieties: [
      'Common Chives: Fine hollow leaves with purple pom-pom flowers. Mild onion flavor. Self-seeds readily. 60 days from seed.',
      'Garlic Chives: Flat leaves with garlic flavor, white flowers. Stronger flavor than common chives. 60-80 days. Also called Chinese chives.'
    ]),
  Plant(name: 'Cilantro', code: 'CIL', icon: '🌿', color: '#10b981', type: 'herb', plantAfterFrostDays: -7, startIndoorsWeeks: 0, harvestWeeks: 6, sqftSpacing: 4, lightLevel: 'high', supportsFall: true, fallPlantBeforeFrostDays: 28, fallStartIndoorsWeeks: 0,
    careInstructions: 'Fast-bolting herb best succession planted every 2-3 weeks. Prefers cool weather; bolts quickly in heat. Let some plants go to seed to harvest coriander (seed form). Both leaves and seeds widely used in cooking. Grows best in spring and fall.',
    watering: 'Regular water to delay bolting. Provide 1 inch per week. Keep soil consistently moist.',
    soil: 'Well-draining soil with pH 6.2-6.8. Light fertilizer only.',
    companions: 'Plant with tomatoes and spinach. Repels aphids. Avoid fennel.',
    varieties: [
      'Slow-Bolt Cilantro: Bred for slower bolting in heat. Produces leaves longer than standard types. 50-55 days to seed.',
      'Calypso: Very slow to bolt with thick stems and abundant leaves. Good for warm climates. 50-60 days.'
    ]),
  Plant(name: 'Collard Greens', code: 'COL', icon: '🥬', color: '#166534', type: 'vegetable', plantAfterFrostDays: -14, startIndoorsWeeks: 4, harvestWeeks: 11, sqftSpacing: 1, cellsRequired: 2, lightLevel: 'low', supportsFall: true, fallPlantBeforeFrostDays: 70, fallStartIndoorsWeeks: 0, tips: ['Flavor improves after frost'],
    careInstructions: 'Heat-tolerant brassica that does not form heads. Harvest outer leaves continuously, leaving center to produce more. Can harvest for months. Frost significantly improves flavor by sweetening leaves. One of the most cold-hardy vegetables.',
    watering: 'Regular watering produces tender leaves. Provide 1-1.5 inches per week. Can tolerate some drought but leaves become tougher.',
    soil: 'Adaptable to various soils. Prefers pH 6.0-6.5. Benefits from compost but less demanding than other brassicas. Side-dress with nitrogen fertilizer for continuous production.',
    companions: 'Plant with onions, potatoes, and herbs. Works well near taller crops for summer shade.',
    varieties: [
      'Georgia Southern: Traditional heirloom with large blue-green leaves. Very heat and cold tolerant. Classic Southern cooking green. Ready in 60-75 days, can harvest smaller leaves earlier.',
      'Champion: Slow-bolting hybrid excellent for spring planting. Productive over long season. Slightly more tender leaves than Georgia. Good disease resistance. 60-70 days.',
      'Morris Heading: Forms loose heads rather than open rosette. Easier to harvest all at once. Good for those who prefer traditional cabbage-like harvest. 80-85 days.',
      'Flash: Very fast-maturing (55 days) with tender, sweet leaves. Good for succession planting and containers. More bolt-resistant in heat than traditional types.'
    ]),
  Plant(name: 'Corn', code: 'CRN', icon: '🌽', color: '#f59e0b', type: 'vegetable', plantAfterFrostDays: 10, startIndoorsWeeks: 0, harvestWeeks: 11, sqftSpacing: 1, lightLevel: 'high', tips: ['Plant in blocks for pollination'],
    careInstructions: 'Plant in blocks (minimum 4x4) rather than single rows to ensure good wind pollination and full ears. Each stalk produces 1-2 ears. Harvest when silks are brown and kernels squirt milky juice when punctured. Best eaten within hours of harvest for maximum sweetness.',
    watering: 'Heavy water needs, especially during tasseling and ear development. Provide 1.5-2 inches per week. Consistent moisture prevents poorly filled ears.',
    soil: 'Rich soil with lots of nitrogen. pH 6.0-6.8. Corn is a very heavy feeder. Side-dress with nitrogen when knee-high and again when tassels appear.',
    companions: 'Traditional Three Sisters method: plant with beans (which climb cornstalks and fix nitrogen) and squash (which shades soil). Avoid tomatoes.',
    varieties: [
      'Silver Queen: Classic white sweet corn with outstanding flavor. 92 days, needs long warm season. Large 8-9 inch ears with tender, juicy kernels. Old-fashioned corny flavor.',
      'Bodacious: Yellow supersweet hybrid ready in 75 days. Very sweet and holds quality longer after harvest. Good for direct market. Needs isolation from other corn types.',
      'Peaches and Cream: Bicolor corn mixing white and yellow kernels. 80-85 days. Balanced sweetness between old and supersweet types. Great for freezing and canning.',
      'Glass Gem: Ornamental Indian corn with translucent, jewel-toned kernels in rainbow colors. 100-110 days. Not for fresh eating but perfect for decoration and flour. Absolutely stunning.'
    ]),
  Plant(name: 'Cucumber', code: 'CUC', icon: '🥒', color: '#15803d', type: 'vegetable', plantAfterFrostDays: 14, startIndoorsWeeks: 0, harvestWeeks: 7, sqftSpacing: 2, lightLevel: 'high', cellsRequired: 2,
    careInstructions: 'Train vines on trellis to save space and keep fruits clean. Harvest regularly to encourage continued production. Pick cucumbers when they reach desired size but before they yellow.',
    watering: 'Water deeply and consistently, 1-2 inches per week. Irregular watering causes bitter fruit. Mulch to retain moisture and keep soil temperature stable.',
    soil: 'Rich, well-draining soil with pH 6.0-7.0. Mix in plenty of compost. Side-dress with compost when vines start to run.',
    companions: 'Plant with beans, peas, radishes, and dill. Avoid planting near melons or potatoes.',
    varieties: [
      'Slicing Cucumbers: For fresh eating. Straight Eight produces 8-inch uniform dark green fruits, classic flavor on vigorous vines. Marketmore 76 has excellent disease resistance to mosaic virus and scab, more reliable in humid climates with longer harvest period.',
      'Pickling Cucumbers: Shorter, thicker fruits stay crisp when pickled. Boston Pickling has blocky 3-4 inch fruits, warty skin holds brine well. National Pickling is similar but produces more heavily over a longer season, harvest at 2-5 inches depending on pickle size desired.',
      'Specialty Cucumbers: Unique varieties worth trying. Lemon cucumber has round yellow fruits with mild, sweet flavor and tender skin. Armenian cucumber (technically a melon) is ribbed, grows 12-15 inches long with mild flavor that never gets bitter.',
      'Compact Bush Varieties: No sprawling vines needed. Bush Champion grows only 2-3 feet with full-size 8-inch fruits, great for small gardens. Patio Snacker is a container variety producing 8-inch cukes on 18-24 inch plants, perfect for pots or hanging baskets.'
    ]),
  Plant(name: 'Dill', code: 'DIL', icon: '🌿', color: '#86efac', type: 'herb', plantAfterFrostDays: 0, startIndoorsWeeks: 0, harvestWeeks: 8, sqftSpacing: 9, lightLevel: 'high',
    careInstructions: 'Annual herb with feathery foliage and edible seeds. Direct sow as it dislikes transplanting. Harvest leaves before flowering. Let some plants flower for seeds and to attract beneficial insects. Self-seeds readily. Succession plant for continuous harvest.',
    watering: 'Moderate water. Provide 1 inch per week. Established plants moderately drought-tolerant.',
    soil: 'Well-draining soil with pH 5.5-6.5. Moderate fertility.',
    companions: 'Plant with cucumbers, lettuce, and brassicas. Attracts beneficial insects. Avoid carrots and fennel.',
    varieties: [
      'Bouquet: Compact variety (2-3 feet) good for small gardens and containers. Quick maturing (40-55 days). Heavy leaf production.',
      'Mammoth: Tall variety (3-4 feet) grown primarily for seed heads for pickling. 70-90 days. Traditional dill pickle variety.'
    ]),
  Plant(name: 'Eggplant', code: 'EGG', icon: '🍆', color: '#9333ea', type: 'vegetable', plantAfterFrostDays: 14, startIndoorsWeeks: 8, harvestWeeks: 12, sqftSpacing: 1, cellsRequired: 2, lightLevel: 'high',
    careInstructions: 'Heat-loving plant needing warm soil and air temperatures. Start indoors 8-10 weeks before transplanting. Harvest when skin is glossy and firm. Dull skin means overripe. Cut fruit with pruners, do not pull. Some varieties can be bitter if stressed or overripe.',
    watering: 'Consistent moisture for best production. Provide 1-2 inches per week. Mulch to maintain soil temperature and moisture. Stress causes bitter fruit.',
    soil: 'Rich, well-draining soil with pH 5.5-6.8. Heavy feeder needing lots of compost. Side-dress with fertilizer when flowering begins.',
    companions: 'Plant with beans and peppers. Avoid tomatoes which compete for nutrients.',
    varieties: [
      'Black Beauty: Classic large purple eggplant (1-2 lbs). Reliable and productive. 75-80 days. Traditional texture and flavor for all cooking methods.',
      'Ichiban: Japanese type with long, slender fruits (10-12 inches). Tender skin, few seeds, mild flavor. Very productive. 60-70 days. Excellent for grilling and stir-frying.',
      'Fairy Tale: Small striped eggplant (4 inches long). Quick maturing (50-65 days). Tender, never bitter. Perfect for containers and roasting whole.'
    ]),
  Plant(name: 'Fennel', code: 'FEN', icon: '🌿', color: '#a3e635', type: 'herb', plantAfterFrostDays: 0, startIndoorsWeeks: 4, harvestWeeks: 12, sqftSpacing: 4, lightLevel: 'high', tips: ['Avoid planting near dill or coriander'],
    careInstructions: 'Two types: Florence fennel grown for bulb, herb fennel for leaves/seeds. Bolts easily in heat or transplant shock. Direct sow or start in pots and transplant carefully. Harvest bulbs when tennis-ball sized. Hill soil around bulbs to blanch. All parts edible with anise flavor.',
    watering: 'Consistent moisture prevents bolting. Provide 1-2 inches per week.',
    soil: 'Rich, well-draining soil with pH 5.5-7.0. Add compost before planting.',
    companions: 'Inhibits growth of many plants. Best grown alone or with dill-family. Avoid tomatoes, beans, kohlrabi.',
    varieties: [
      'Florence Fennel: Grown for white bulb at base. Sweet anise flavor. 65-90 days. Use fresh in salads or roasted.',
      'Bronze Fennel: Ornamental herb fennel with copper foliage. Grown for leaves and seeds. Does not form bulb. Very attractive in garden.'
    ]),
  Plant(name: 'Garlic', code: 'GAR', icon: '🧄', color: '#78350f', type: 'vegetable', plantAfterFrostDays: -180, startIndoorsWeeks: 0, harvestWeeks: 30, sqftSpacing: 4, lightLevel: 'high', tips: ['Best planted in fall', 'Mulch over winter'],
    careInstructions: 'Plant individual cloves in fall (October-November) for summer harvest. Requires cold period (vernalization) to form bulbs. Remove flower scapes in spring for larger bulbs (scapes are edible). Harvest when lower leaves brown. Cure in warm, dry place for 2-3 weeks before storing.',
    watering: 'Regular water during spring growth. Provide 1 inch per week. Stop watering 2-3 weeks before harvest to allow bulbs to mature and skins to form.',
    soil: 'Well-draining soil with pH 6.0-7.0. Add compost in fall. Side-dress with nitrogen in early spring when growth resumes.',
    companions: 'Plant with roses, tomatoes, and brassicas. Repels aphids and many pests. Avoid peas and beans.',
    varieties: [
      'Hardneck Garlic: Produces flower scape and larger, easier-to-peel cloves. More cold-hardy. Rich, complex flavor. Stores 3-5 months. Popular types: Rocambole, Porcelain, Purple Stripe.',
      'Softneck Garlic: No flower scape, more cloves per bulb. Better for warm climates and long storage (6-12 months). Milder flavor. The type usually found in grocery stores. Artichoke and Silverskin varieties.'
    ]),
  Plant(name: 'Green Onions', code: 'GON', icon: '🧅', color: '#65a30d', type: 'vegetable', plantAfterFrostDays: -21, startIndoorsWeeks: 0, harvestWeeks: 8, sqftSpacing: 16, lightLevel: 'high', supportsFall: true, fallPlantBeforeFrostDays: 56, fallStartIndoorsWeeks: 0, tips: ['Can regrow from roots'],
    careInstructions: 'Fast-growing onions harvested before bulbing. Sow seeds thickly and harvest when pencil-thick. Can regrow from roots if you leave 1-2 inches of white base. Succession plant every 2-3 weeks. Both white and green parts are edible.',
    watering: 'Keep soil consistently moist. Water lightly and frequently, about 1 inch per week.',
    soil: 'Well-draining soil with pH 6.0-7.0. Not as demanding as bulb onions. Benefits from compost.',
    companions: 'Plant with carrots, lettuce, and brassicas. Takes up little space, good for intercropping.',
    varieties: [
      'Evergreen Hardy White: Cold-hardy bunching onion that overwinters in zones 5+. Can harvest year-round in mild climates. Mild flavor. 60-120 days depending on size desired.',
      'Tokyo Long White: Quick-growing Japanese variety with long white stems. Mild, sweet flavor. Ready in 60-70 days. Bolt-resistant.'
    ]),
  Plant(name: 'Kale', code: 'KAL', icon: '🥬', color: '#1e3a8a', type: 'vegetable', plantAfterFrostDays: -21, startIndoorsWeeks: 5, harvestWeeks: 8, sqftSpacing: 1, cellsRequired: 2, lightLevel: 'low', supportsFall: true, fallPlantBeforeFrostDays: 70, fallStartIndoorsWeeks: 5,
    careInstructions: 'Super hardy green that improves with frost. Harvest outer leaves continuously while letting center grow. Can harvest through winter in many climates with frost protection. One of the most nutrient-dense vegetables. Young leaves are tender for salads; mature leaves better cooked.',
    watering: 'Consistent moisture produces tender leaves. Provide 1-1.5 inches per week. Mulch to retain moisture and keep roots cool.',
    soil: 'Adaptable to most soils. pH 6.0-7.0. Benefits from nitrogen fertilization. Add compost before planting and side-dress monthly.',
    companions: 'Plant with onions, herbs, and beets. Avoid tomatoes, strawberries, and pole beans.',
    varieties: [
      'Lacinato (Dinosaur) Kale: Italian heirloom with dark blue-green, deeply textured leaves. More tender and sweeter than curly kale. Stands well in cold. Perfect for massaged kale salads. 60-65 days.',
      'Winterbor: Extremely cold-hardy curly kale with tightly curled leaves. Can overwinter in zone 5+. Beautiful blue-green color. Very productive. Classic texture for kale chips. 60 days.',
      'Red Russian: Tender, sweet kale with flat, oak-shaped leaves and purple stems. Fastest growing (50 days). Less bitter, good for salads even when large. Beautiful ornamental plant.',
      'Dwarf Blue Curled: Compact variety (12-15 inches) perfect for containers. Tightly curled blue-green leaves. Very cold hardy. Great for small gardens. 55-60 days.'
    ]),
  Plant(name: 'Kohlrabi', code: 'KOH', icon: '🥬', color: '#a78bfa', type: 'vegetable', plantAfterFrostDays: -14, startIndoorsWeeks: 4, harvestWeeks: 8, sqftSpacing: 4, lightLevel: 'high', supportsFall: true, fallPlantBeforeFrostDays: 56, fallStartIndoorsWeeks: 0, tips: ['Harvest bulbs at 2-3 inches'],
    careInstructions: 'Member of cabbage family grown for swollen stem "bulb". Fast-growing (45-60 days). Best harvested young (2-3 inches) for tender, sweet flavor. Larger bulbs become woody. Peel tough outer layer. Tastes like mild, sweet broccoli stem. Can eat raw or cooked.',
    watering: 'Consistent moisture for tender bulbs. Provide 1 inch per week.',
    soil: 'Well-draining soil with pH 6.0-7.5. Moderate fertility. Add compost before planting.',
    companions: 'Plant with beets, onions, and cucumbers. Avoid tomatoes, peppers, and pole beans.',
    varieties: [
      'Kolibri: Purple variety with white flesh. Crisp and sweet. Slow to become woody. 50-60 days. Beautiful color.',
      'Winner: Pale green variety with excellent flavor. Quick maturing (43-55 days). Good for succession planting.'
    ]),
  Plant(name: 'Leeks', code: 'LEK', icon: '🧅', color: '#6d7c26', type: 'vegetable', plantAfterFrostDays: -14, startIndoorsWeeks: 8, harvestWeeks: 16, sqftSpacing: 4, lightLevel: 'high', tips: ['Hill soil to blanch stems'],
    careInstructions: 'Long-season crop needing 100-120 days. Transplant when pencil-thick. Hill soil around stems as they grow to blanch and increase tender white portion. Very cold-hardy, can harvest through winter. Flavor improves with frost. Milder than onions.',
    watering: 'Consistent moisture produces tender leeks. Provide 1 inch per week throughout long growing season.',
    soil: 'Rich, deep soil with pH 6.0-7.0. Add lots of compost. Side-dress monthly with nitrogen fertilizer.',
    companions: 'Plant with carrots, celery, and onions. Avoid beans and peas.',
    varieties: [
      'King Richard: Fast-maturing leek (75 days) with long, slender shanks. Good for fall harvest. Less cold-hardy than winter types.',
      'Giant Musselburgh: Large, thick shanks. Very cold-hardy, overwinters well. Traditional Scottish variety. 105 days to maturity but can harvest larger after frost.',
      'Tadorna Blue: Extremely cold-hardy winter leek with blue-green leaves. Best flavor after hard frost. Can harvest all winter in zones 5-6. 110-120 days.'
    ]),
  Plant(name: 'Lettuce', code: 'LET', icon: '🥬', color: '#65a30d', type: 'vegetable', plantAfterFrostDays: -21, startIndoorsWeeks: 0, harvestWeeks: 7, sqftSpacing: 2, lightLevel: 'low', supportsFall: true, fallPlantBeforeFrostDays: 45, fallStartIndoorsWeeks: 0, tips: ['Provide shade in heat'],
    careInstructions: 'Lettuce is a cool-season crop that bolts in heat. Plant in early spring or fall for best results. Provide afternoon shade in warmer weather. Harvest outer leaves continuously for cut-and-come-again harvesting.',
    watering: 'Keep soil consistently moist. Water frequently with shallow watering, about 1 inch per week. Lettuce has shallow roots and needs regular moisture.',
    soil: 'Rich, loose soil with plenty of compost. pH 6.0-7.0. Side-dress with nitrogen fertilizer midseason for leafy growth.',
    companions: 'Plant with carrots, radishes, and strawberries. Benefits from taller plants providing afternoon shade.',
    varieties: [
      'Loose Leaf Lettuce: Best for continuous harvesting. Black Seeded Simpson has light green, frilly leaves with mild flavor and is the fastest maturing (45 days). Oak Leaf has distinctive oak-shaped leaves, slower to bolt in heat, and comes in red or green varieties.',
      'Romaine (Cos) Lettuce: Upright heads with crisp texture, classic Caesar salad type. Parris Island Cos is heat-tolerant and disease-resistant with traditional tall heads. Little Gem is a mini romaine (6 inches tall) with sweet, tender hearts, perfect for small gardens or containers.',
      'Butterhead (Bibb) Lettuce: Forms loose heads with buttery, tender leaves. Buttercrunch has excellent flavor with crunchy ribs and soft outer leaves. Tom Thumb is a miniature variety (4 inches) that matures in 45 days, ideal for succession planting in tight spaces.',
      'Crisphead (Iceberg) Lettuce: Forms tight, crunchy heads but more challenging to grow. Great Lakes is an improved iceberg that tolerates some heat. Summertime is bred for heat resistance and resists bolting, allowing summer production where others fail.'
    ]),
  Plant(name: 'Melon', code: 'MLN', icon: '🍈', color: '#10b981', type: 'fruit', plantAfterFrostDays: 21, startIndoorsWeeks: 0, harvestWeeks: 12, sqftSpacing: 1, lightLevel: 'high', cellsRequired: 4,
    careInstructions: 'Heat-loving crop needing warm soil (70°F+) and long season. Melons are ripe when they slip easily from vine with gentle pressure. Flavor is best when vine-ripened. Reduce watering as fruits ripen for sweeter flavor.',
    watering: 'Regular water during growth, about 1-2 inches per week. Reduce watering when fruits start ripening to concentrate sugars. Avoid wetting foliage.',
    soil: 'Rich, well-draining soil with pH 6.0-7.0. Add lots of compost. Side-dress with compost when vines start running.',
    companions: 'Plant with corn and squash. Avoid potatoes.',
    varieties: [
      'Minnesota Midget: Small (4 inch) cantaloupe bred for short seasons and cool climates. Ready in just 60-65 days. Sweet and productive. Good for containers.',
      'Sarah\'s Choice: Hybrid cantaloupe with excellent disease resistance. 75 days. Sweet orange flesh, reliable even in challenging conditions.',
      'Earligold: Early cantaloupe (68 days) with good flavor. Medium-sized fruits, dependable producer for northern gardens.'
    ]),
  Plant(name: 'Mint', code: 'MNT', icon: '🌿', color: '#34d399', type: 'herb', plantAfterFrostDays: 0, startIndoorsWeeks: 0, harvestWeeks: 52, sqftSpacing: 1, lightLevel: 'high', tips: ['Spreads aggressively; container recommended'],
    careInstructions: 'Extremely vigorous perennial herb that spreads aggressively via runners. Best grown in containers to prevent takeover. Harvest leaves regularly to encourage bushiness. Cut back before flowering for best flavor. Overwinters in most climates. Divide every 2-3 years.',
    watering: 'Likes consistent moisture. Water when top inch of soil is dry. Can tolerate some shade and more water than most herbs.',
    soil: 'Average soil with pH 6.0-7.0. Not fussy. Grows vigorously in most conditions.',
    companions: 'Repels many pests. Plant near cabbage and tomatoes. Isolate from other herbs to prevent spreading.',
    varieties: [
      'Spearmint: Classic mint flavor, less aggressive than peppermint. Most popular for cooking and tea. Hardy to zone 4.',
      'Peppermint: Strong menthol flavor, very vigorous. Best for tea and medicinal uses. Hardy to zone 3.'
    ]),
  Plant(name: 'Onion', code: 'ONI', icon: '🧅', color: '#92400e', type: 'vegetable', plantAfterFrostDays: -21, startIndoorsWeeks: 0, harvestWeeks: 12, sqftSpacing: 12, lightLevel: 'high',
    careInstructions: 'Onions are day-length sensitive: long-day types for northern gardens, short-day for southern. Plant sets or transplants early. Harvest when tops fall over naturally. Cure in warm, airy place for 2-3 weeks until outer skins are papery. Properly cured onions store for months.',
    watering: 'Regular watering during bulb development. Provide 1 inch per week. Stop watering when tops begin falling over to allow bulbs to mature and skin to form.',
    soil: 'Rich, well-draining soil with pH 6.0-6.8. Onions are heavy feeders. Add compost and side-dress with nitrogen fertilizer every 2-3 weeks until bulbing begins.',
    companions: 'Plant with carrots, beets, and lettuce. Repels many pests. Avoid peas and beans.',
    varieties: [
      'Yellow Sweet Spanish: Large (1 lb) mild onions for northern gardens (long-day type). Good storage onion lasting 3-5 months. 110-120 days. Classic burger onion.',
      'Walla Walla: Sweet jumbo onions from Washington state. Mild enough to eat raw. Short-day to intermediate. Poor storage (1-2 months) so use fresh. 125 days.',
      'Red Wing: Storage red onion with good flavor retention. Long-day type. Stores 4-6 months. Beautiful color, pungent flavor softens in storage. 105 days.',
      'Cipollini: Small flat Italian onions (2 inches diameter). Sweet and mild, perfect for roasting whole or pearl onions. Short season (60-70 days). Limited storage.'
    ]),
  Plant(name: 'Oregano', code: 'ORE', icon: '🌿', color: '#059669', type: 'herb', plantAfterFrostDays: 0, startIndoorsWeeks: 6, harvestWeeks: 52, sqftSpacing: 1, lightLevel: 'high',
    careInstructions: 'Hardy perennial herb that improves with age. Flavor intensifies when dried. Cut back to 6 inches in early summer to encourage bushy growth. Harvest before flowers open for best flavor. Easy to overwinter. Divide clumps every 3-4 years.',
    watering: 'Drought-tolerant once established. Water when soil is dry 2 inches down. Prefers drier conditions.',
    soil: 'Well-draining soil with pH 6.0-8.0. Does not need rich soil. Add sand or gravel if drainage is poor.',
    companions: 'Plant with tomatoes, peppers, and eggplant. Repels many pests.',
    varieties: [
      'Greek Oregano: Most flavorful variety with strong, pungent taste. True Mediterranean oregano. Hardy to zone 5. Best for Italian and Greek cooking.',
      'Italian Oregano: Milder, sweeter flavor than Greek. Larger leaves. Often a cross between oregano and sweet marjoram. Hardy to zone 5.'
    ]),
  Plant(name: 'Parsley', code: 'PAR', icon: '🌿', color: '#16a34a', type: 'herb', plantAfterFrostDays: -14, startIndoorsWeeks: 0, harvestWeeks: 10, sqftSpacing: 2, lightLevel: 'high', supportsFall: true, fallPlantBeforeFrostDays: 60, fallStartIndoorsWeeks: 0,
    careInstructions: 'Biennial grown as annual. Very slow to germinate (2-4 weeks) - soak seeds overnight to speed up. Cut outer stems to encourage new growth. Very cold-hardy, one of last herbs standing in fall. Goes to seed in second year.',
    watering: 'Consistent moisture for tender leaves. Provide 1 inch per week. Can tolerate partial shade.',
    soil: 'Rich, moist soil with pH 6.0-7.0. Add compost before planting. Benefits from monthly feeding.',
    companions: 'Plant with tomatoes, carrots, and asparagus. Attracts beneficial insects. Host plant for swallowtail butterflies.',
    varieties: [
      'Italian Flat-Leaf: More flavorful than curly types. Stronger, more complex taste. Easier to chop. 75-80 days. Preferred for cooking.',
      'Curly Parsley: Milder flavor, decorative frilly leaves. Traditional garnish. 70-80 days. Very cold-hardy, can overwinter in zones 7+.'
    ]),
  Plant(name: 'Parsnips', code: 'PRS', icon: '🥕', color: '#fef3c7', type: 'vegetable', plantAfterFrostDays: -14, startIndoorsWeeks: 0, harvestWeeks: 16, sqftSpacing: 16, lightLevel: 'low', tips: ['Flavor improves after frost'],
    careInstructions: 'Long-season root vegetable needing 120 days. Slow to germinate (2-4 weeks) - keep soil moist. Best planted early spring for fall harvest. Frost converts starches to sugar, greatly improving flavor. Can overwinter in ground with mulch. Tastes sweet and nutty, like carrot-potato hybrid.',
    watering: 'Keep soil moist until germination, then 1 inch per week. Consistent moisture prevents forking.',
    soil: 'Deep, loose soil (12+ inches) free of rocks. pH 6.0-7.0. Avoid fresh manure which causes forking.',
    companions: 'Plant with bush beans and peppers. Avoid carrots and celery.',
    varieties: [
      'Hollow Crown: Traditional variety with long (12-15 inch) smooth roots. Sweet flavor. 120 days. Very cold-hardy, can overwinter.',
      'Gladiator: Shorter, thicker roots (10 inches). Smooth skin, few side roots. Disease resistant. 110 days. Good for heavy soils.'
    ]),
  Plant(name: 'Pea', code: 'PEA', icon: '🫑', color: '#22c55e', type: 'vegetable', plantAfterFrostDays: -28, startIndoorsWeeks: 0, harvestWeeks: 10, sqftSpacing: 8, lightLevel: 'low',
    careInstructions: 'Peas fix nitrogen and improve soil. Plant as early as soil can be worked; they need cool weather. Provide support for all except dwarf types. Harvest regularly to encourage production. Snap peas eaten pod and all; shell peas need shelling; snow peas picked flat.',
    watering: 'Moderate watering during growth, increase when flowering and pods forming. Provide 1 inch per week. Avoid overwatering which promotes disease.',
    soil: 'Well-draining soil with pH 6.0-7.5. Peas fix nitrogen so avoid high-nitrogen fertilizer. Add phosphorus and potassium. Inoculate seeds with rhizobium bacteria for best nitrogen fixation.',
    companions: 'Plant with carrots, radishes, and corn. Fix nitrogen benefiting neighboring plants. Avoid onions and garlic.',
    varieties: [
      'Sugar Snap: Original edible-pod pea with sweet, crunchy pods and full-size peas inside. Vines grow 5-6 feet needing strong support. 60-70 days. Kids love eating them raw.',
      'Lincoln Shelling Peas: Classic English pea for shelling. Heavy yields of 3-4 inch pods with 6-8 sweet peas each. Vines 24-30 inches. 65-70 days. Best for freezing.',
      'Oregon Sugar Pod II: Disease-resistant snow pea with flat, tender pods. Pick when pods are 3-4 inches before peas swell. Vines 28 inches. 68 days. Excellent stir-fry type.',
      'Tom Thumb: Dwarf shelling pea growing only 8-10 inches, no support needed. Tiny but productive. Perfect for containers and small gardens. Quick maturing at 50 days.'
    ]),
  Plant(name: 'Pepper', code: 'PEP', icon: '🌶️', color: '#ea580c', type: 'vegetable', plantAfterFrostDays: 14, startIndoorsWeeks: 8, harvestWeeks: 12, sqftSpacing: 1, lightLevel: 'high',
    careInstructions: 'Peppers thrive in warm weather and need consistent warmth to set fruit. Stake taller varieties to prevent branches from breaking under fruit weight. Harvest regularly to encourage more production.',
    watering: 'Water regularly, about 1 inch per week. Keep soil evenly moist but not waterlogged. Reduce watering slightly as fruits mature for better flavor.',
    soil: 'Well-draining soil rich in organic matter, pH 6.0-7.0. Work in compost and balanced fertilizer at planting. Avoid over-fertilizing with nitrogen which promotes leaves over fruit.',
    companions: 'Grows well with basil, onions, and carrots. Keep away from beans and fennel.',
    varieties: [
      'Sweet Bell Peppers: California Wonder is the classic blocky bell pepper with thick walls, turning from green to red when fully ripe. King of the North is a northern variety that sets fruit in cooler temperatures and matures earlier, ideal for short growing seasons.',
      'Hot Peppers: Jalapeño (2,500-8,000 Scoville) is versatile for pickling, fresh salsa, or stuffing with medium heat. Cayenne (30,000-50,000 Scoville) is thin-walled and perfect for drying into powder. Habanero (100,000-350,000 Scoville) has intense heat with fruity, citrus flavor.',
      'Specialty Grilling Peppers: Shishito and Padrón are mild peppers perfect for blistering in a hot pan. Thin-walled with sweet flavor, though about 1 in 10 will be surprisingly spicy. Popular in tapas and as appetizers.',
      'Mini Sweet Peppers: Lunchbox peppers are small snacking peppers in red, orange, and yellow. Very sweet with no bitterness, even when green. Compact plants produce heavily and fruits are perfect for kids lunch boxes.'
    ]),
  Plant(name: 'Potato', code: 'POT', icon: '🥔', color: '#a16207', type: 'vegetable', plantAfterFrostDays: 0, startIndoorsWeeks: 0, harvestWeeks: 12, sqftSpacing: 1, lightLevel: 'high', tips: ['Hill soil or mulch around stems'],
    careInstructions: 'Plant certified seed potatoes 2-4 weeks before last frost. Hill soil or mulch around stems as plants grow to increase yield and prevent green tubers. Stop watering 2 weeks before harvest. Harvest new potatoes anytime; full-size when plants flower or foliage dies back. Cure in dark before storing.',
    watering: 'Consistent moisture especially during tuber formation. Provide 1-2 inches per week. Uneven watering causes knobby potatoes. Stop watering as foliage yellows.',
    soil: 'Loose, acidic soil (pH 4.8-6.0). Avoid lime which encourages scab disease. Add sulfur to lower pH if needed. Well-draining soil prevents rot.',
    companions: 'Plant with beans, corn, and marigolds. Avoid tomatoes, peppers, eggplant (same family, shared diseases).',
    varieties: [
      'Yukon Gold: Golden flesh, buttery flavor. All-purpose potato good for baking, boiling, or frying. Thin skin. Moderately early (70-90 days). Excellent fresh but only stores 2-3 months.',
      'Russet Burbank: Classic baking potato with high starch, fluffy texture. Thick skin, white flesh. Long season (100-120 days). Excellent long-term storage (4-6 months).',
      'Red Pontiac: Red skin, white flesh. Waxy texture perfect for potato salad and roasting. Early (70-80 days). Disease resistant. Stores moderately well.',
      'Fingerling: Small, finger-shaped potatoes with dense, waxy texture. Various colors available. Nutty, rich flavor. 75-85 days. Gourmet types for roasting whole.'
    ]),
  Plant(name: 'Pumpkin', code: 'PUM', icon: '🎃', color: '#ea580c', type: 'fruit', plantAfterFrostDays: 14, startIndoorsWeeks: 0, harvestWeeks: 14, sqftSpacing: 1, lightLevel: 'high', cellsRequired: 4, tips: ['Very sprawling; trellis small varieties'],
    careInstructions: 'Space-hungry vining plants needing 50-120 square feet per plant depending on variety. For larger pumpkins, limit to 2-3 fruits per vine. Harvest when fully colored and rind is hard (can\'t dent with fingernail). Leave 3-4 inches of stem attached. Cure in sun for 7-10 days to harden rind.',
    watering: 'Regular water during growth, 1-2 inches per week. Water at base to prevent leaf diseases. Reduce watering as pumpkins ripen.',
    soil: 'Rich soil with pH 6.0-6.8. Heavy feeder needing lots of compost. Side-dress with compost when vines start running.',
    companions: 'Plant with corn and beans (three sisters method). Avoid potatoes.',
    varieties: [
      'Sugar Pie: Small (6-8 lb) cooking pumpkin with sweet, fine-grained flesh. Best for pies and baking. 100-110 days. Not decorative but superior flavor.',
      'Jack O\' Lantern: Classic carving pumpkin (10-20 lbs) with sturdy stems. 110-120 days. Uniform shape and size.',
      'Cinderella (Rouge Vif d\'Etampes): Flat, deeply ribbed French heirloom. 10-15 lbs. Beautiful orange color. Excellent for cooking and display. 110 days.'
    ]),
  Plant(name: 'Radish', code: 'RAD', icon: '🔴', color: '#ef4444', type: 'vegetable', plantAfterFrostDays: -21, startIndoorsWeeks: 0, harvestWeeks: 4, sqftSpacing: 16, lightLevel: 'low', supportsFall: true, fallPlantBeforeFrostDays: 28, fallStartIndoorsWeeks: 0,
    careInstructions: 'One of the fastest vegetables (20-30 days), perfect for kids and impatient gardeners. Succession plant every week for continuous harvest. Pull when roots reach size (usually 1 inch), as they become pithy and hot if left too long. Great for intercropping between slower vegetables.',
    watering: 'Consistent moisture prevents hot, woody radishes. Water regularly, about 1 inch per week. Even moisture produces crisp, mild roots.',
    soil: 'Loose, well-draining soil free of rocks. pH 6.0-7.0. Avoid fresh manure which causes forking. Light fertilization only.',
    companions: 'Plant with cucumbers, lettuce, and peas. Use as trap crop for flea beetles. Avoid hyssop.',
    varieties: [
      'Cherry Belle: Classic round red radish with white flesh. Reliable and quick (22-25 days). Mild when harvested promptly. Good for beginners and kids.',
      'French Breakfast: Oblong red radish with white tip. Crisp, mild, and slightly sweet. Popular bistro radish. 25-28 days. Perfect with butter and salt.',
      'Watermelon Radish: Large (2-3 inch) radish with white exterior and bright pink-magenta interior. Mild and sweet, beautiful in salads. Slower (55-65 days). Plant in fall for best flavor.',
      'Daikon: Japanese white radish growing 12-18 inches long. Mild flavor, excellent for pickling and fermenting. Takes 50-60 days. Breaks up compacted soil with deep taproot.'
    ]),
  Plant(name: 'Rhubarb', code: 'RHU', icon: '🍃', color: '#6b7280', type: 'vegetable', plantAfterFrostDays: -7, startIndoorsWeeks: 0, harvestWeeks: 52, sqftSpacing: 1, cellsRequired: 4, lightLevel: 'high', tips: ['Do not harvest first season'],
    careInstructions: 'Perennial vegetable producing for 10-15 years once established. Do not harvest first year; light harvest second year. Pull stalks by twisting and pulling at base (don\'t cut). Harvest when stalks are 10+ inches. Remove flower stalks immediately. Only stalks are edible - leaves are toxic.',
    watering: 'Regular water for tender stalks, 1-2 inches per week. Established plants are drought-tolerant but produce better with consistent moisture.',
    soil: 'Rich, well-draining soil with pH 5.5-6.5. Heavy feeder. Add compost annually in spring.',
    companions: 'Plant with beans, onions, and brassicas. Benefits from nearby garlic to deter pests.',
    varieties: [
      'Victoria: Most popular variety. Green stalks with pink base. Very cold-hardy (zone 3). Reliable and productive. Tart flavor excellent for cooking.',
      'Canada Red: Bright red stalks holding color when cooked. Sweeter than green varieties. Hardy to zone 3. Beautiful in the garden.'
    ]),
  Plant(name: 'Rosemary', code: 'ROS', icon: '🌿', color: '#14532d', type: 'herb', plantAfterFrostDays: 0, startIndoorsWeeks: 10, harvestWeeks: 52, sqftSpacing: 1, lightLevel: 'high',
    careInstructions: 'Tender perennial (hardy only to zone 7-8). Slow-growing woody herb. Prefers drier conditions - overwatering is most common problem. Bring indoors for winter in cold climates. Can grow as large shrub (3-4 feet) in ideal conditions. Harvest stems with sharp scissors.',
    watering: 'Water sparingly. Allow soil to dry between waterings. Established plants very drought-tolerant. Overwatering causes root rot.',
    soil: 'Well-draining, sandy soil with pH 6.0-7.5. Does not need rich soil. Excellent drainage essential.',
    companions: 'Plant with cabbage, beans, and carrots. Repels many pests.',
    varieties: [
      'Arp: Most cold-hardy variety, to zone 6. Upright growth with gray-green leaves. Lemon scent. Good for cold climates.',
      'Tuscan Blue: Upright growth to 5-6 feet. Dark blue flowers. Traditional culinary variety. Hardy to zone 8.'
    ]),
  Plant(name: 'Rutabaga', code: 'RUT', icon: '🟡', color: '#eab308', type: 'vegetable', plantAfterFrostDays: -14, startIndoorsWeeks: 0, harvestWeeks: 14, sqftSpacing: 4, lightLevel: 'low', supportsFall: true, fallPlantBeforeFrostDays: 90, fallStartIndoorsWeeks: 0, tips: ['Flavor improves after frost'],
    careInstructions: 'Cold-weather root vegetable, a cross between turnip and cabbage. Plant mid-summer for fall harvest. Flavor sweetens after frost. Can harvest from fall through winter - very cold-hardy. Harvest when 3-5 inches diameter. Wax coating helps storage. Stores months in cool conditions.',
    watering: 'Consistent moisture prevents woody, bitter roots. Provide 1 inch per week throughout growing season.',
    soil: 'Well-draining soil with pH 5.5-7.0. Prefers cooler soil. Add compost but avoid fresh manure.',
    companions: 'Plant with peas and onions. Avoid brassicas which share pests and diseases.',
    varieties: [
      'American Purple Top: Classic variety with purple shoulders and yellow flesh. Sweet when grown in cool weather. 90-100 days. Excellent storage.',
      'Laurentian: Canadian variety bred for cold hardiness and disease resistance. Sweet, fine-grained flesh. 95 days. Very winter-hardy.'
    ]),
  Plant(name: 'Sage', code: 'SAG', icon: '🌿', color: '#15803d', type: 'herb', plantAfterFrostDays: 0, startIndoorsWeeks: 8, harvestWeeks: 52, sqftSpacing: 1, lightLevel: 'high',
    careInstructions: 'Hardy perennial herb (zones 4-8). Shrubby plant that can grow 2-3 feet. Harvest before flowering for best flavor. Cut back by one-third in spring to encourage bushy growth. Replace plants every 4-5 years as they become woody. Flavor intensifies when dried.',
    watering: 'Drought-tolerant once established. Water when top 2 inches of soil are dry. Prefers drier conditions.',
    soil: 'Well-draining soil with pH 6.0-7.0. Tolerates poor soil. Good drainage essential.',
    companions: 'Plant with cabbage, carrots, and rosemary. Repels cabbage moths.',
    varieties: [
      'Common Sage: Gray-green leaves, strong classic sage flavor. Most cold-hardy (zone 4). Reliable and traditional. 75 days.',
      'Berggarten: Larger, rounder leaves than common sage. More compact, rarely flowers. Cold-hardy to zone 5. Excellent flavor.'
    ]),
  Plant(name: 'Shallots', code: 'SHA', icon: '🧅', color: '#92400e', type: 'vegetable', plantAfterFrostDays: -21, startIndoorsWeeks: 0, harvestWeeks: 14, sqftSpacing: 9, lightLevel: 'high', tips: ['Each bulb multiplies'],
    careInstructions: 'Plant individual cloves in early spring or fall. Each clove multiplies into cluster of 5-10 bulbs. Harvest when tops fall over and dry. Cure like onions for 2-3 weeks. Milder, sweeter flavor than onions. Excellent storage (6-8 months).',
    watering: 'Regular water during growth, about 1 inch per week. Stop watering when tops begin falling over.',
    soil: 'Well-draining soil with pH 6.0-7.0. Add compost before planting. Side-dress with fertilizer once during season.',
    companions: 'Plant with carrots, beets, and strawberries. Avoid peas and beans.',
    varieties: [
      'French Red Shallot: Traditional elongated shallots with copper-red skin and pink-tinged flesh. Complex, sweet flavor. Best for cooking. 90-120 days.',
      'Dutch Yellow Shallot: Rounder bulbs with golden skin. Milder than French types. Stores well. 90-100 days.'
    ]),
  Plant(name: 'Spinach', code: 'SPI', icon: '🥬', color: '#0f766e', type: 'vegetable', plantAfterFrostDays: -28, startIndoorsWeeks: 0, harvestWeeks: 6, sqftSpacing: 9, lightLevel: 'low', supportsFall: true, fallPlantBeforeFrostDays: 45, fallStartIndoorsWeeks: 0, tips: ['Bolts in heat'],
    careInstructions: 'Fast-growing cool-season green. Harvest outer leaves continuously or cut entire plant. Bolts quickly when days lengthen and temperatures rise. Best grown early spring and fall. Young leaves are tender for salads; cook mature leaves. Highly nutritious superfood.',
    watering: 'Keep soil consistently moist. Provide 1-1.5 inches per week. Stress from drought triggers early bolting.',
    soil: 'Rich, nitrogen-rich soil with pH 6.5-7.0. Add compost before planting. Benefits from nitrogen fertilization for rapid leaf growth.',
    companions: 'Plant with strawberries, peas, and brassicas. Benefits from afternoon shade in late spring.',
    varieties: [
      'Bloomsdale: Heirloom with heavily crinkled, dark green leaves. Slow to bolt for a spinach. Excellent flavor fresh or cooked. 48-55 days. Classic for canning.',
      'Space: Smooth-leaved hybrid, much faster and easier to clean than savoy types. Upright growth makes harvesting easy. Good bolt resistance. 39-45 days.',
      'Tyee: Very cold-hardy with thick, substantial leaves. Overwinter variety in mild climates. Slow bolting in spring. 45-50 days. Excellent disease resistance.',
      'Red Kitten: Smooth red-veined leaves that add color to salads. Fast growing (28-35 days). Less bolt-resistant so best for baby leaf production. Mild flavor.'
    ]),
  Plant(name: 'Squash', code: 'SQW', icon: '🎃', color: '#b45309', type: 'vegetable', plantAfterFrostDays: 10, startIndoorsWeeks: 0, harvestWeeks: 13, sqftSpacing: 1, lightLevel: 'high', cellsRequired: 4,
    careInstructions: 'Winter squash needs long season (80-110 days) and lots of space. Vines can spread 10-20 feet. Harvest when skin is hard and cannot be dented with fingernail. Cure in warm, dry place for 10-14 days to harden skin and improve flavor. Can store for months.',
    watering: 'Deep watering, 1-2 inches per week. Water at soil level to prevent powdery mildew. Reduce watering as fruits mature to improve storage quality.',
    soil: 'Rich, well-draining soil with lots of compost. pH 6.0-6.8. Side-dress with compost when vines start running and again when fruits set.',
    companions: 'Plant with corn and beans (Three Sisters). Avoid potatoes.',
    varieties: [
      'Butternut: Tan pear-shaped squash with sweet orange flesh. 85-100 days. Excellent storage (3-6 months). Small seed cavity, mostly usable flesh. Classic for soups and roasting.',
      'Acorn: Dark green ribbed squash, 1-2 lbs each. Fast for winter squash (75-85 days). Stores 1-2 months. Sweet, nutty flavor. Perfect size for stuffing and baking.',
      'Spaghetti Squash: Unique flesh separates into pasta-like strands when cooked. Yellow oblong fruit 4-8 lbs. 90-100 days. Low-carb pasta substitute. Stores 2-3 months.',
      'Delicata: Sweet potato flavor, thin edible skin. 3-4 inch long fruits. Fast maturing (80-100 days). Stores only 4-8 weeks but worth it for incredible flavor. Compact vines, good for small gardens.'
    ]),
  Plant(name: 'Strawberries', code: 'STR', icon: '🍓', color: '#f43f5e', type: 'fruit', plantAfterFrostDays: -7, startIndoorsWeeks: 0, harvestWeeks: 52, sqftSpacing: 2, lightLevel: 'high', tips: ['Perennial; manage runners'],
    careInstructions: 'Perennial producing for 3-5 years. June-bearing types produce one large crop; everbearing produce smaller amounts all season. Plants send out runners (daughter plants) - manage by pinching or allowing to root. Renovate beds after harvest by mowing and thinning. Mulch heavily for winter.',
    watering: 'Consistent moisture especially during fruiting. Provide 1-1.5 inches per week. Use drip irrigation to prevent fruit rot.',
    soil: 'Well-draining, acidic soil (pH 5.5-6.5). Add sulfur if needed. Avoid areas where tomatoes, peppers, or potatoes grew (disease risk).',
    companions: 'Plant with bush beans, borage, and spinach. Avoid brassicas.',
    varieties: [
      'Jewel: Everbearing with large, sweet berries from June to frost. Good disease resistance. Hardy to zone 3. Productive and reliable.',
      'Seascape: Day-neutral producing continuously in cool weather. Large berries with excellent flavor. Good for containers. Zones 4-9.',
      'Honeoye: June-bearing with large, firm berries. Very cold-hardy (zone 3). Heavy early crop, excellent for freezing. Disease resistant.'
    ]),
  Plant(name: 'Sweet Potato', code: 'SWE', icon: '🍠', color: '#b45309', type: 'vegetable', plantAfterFrostDays: 21, startIndoorsWeeks: 0, harvestWeeks: 16, sqftSpacing: 1, lightLevel: 'high', cellsRequired: 4, tips: ['Plant slips; warm soil'],
    careInstructions: 'Heat-loving crop needing warm soil (75°F+) and long season (100-120 days). Plant "slips" (rooted sprouts). Harvest before frost when leaves start yellowing. Cure at 85°F and high humidity for 7-10 days, then store at 55-60°F. Properly cured sweet potatoes store 6-10 months.',
    watering: 'Water regularly when establishing, then reduce to encourage root development. Provide 1 inch per week, less in late season.',
    soil: 'Well-draining, sandy soil with pH 5.5-6.5. Don\'t over-fertilize with nitrogen which promotes vines over roots. Light fertilizer only.',
    companions: 'Plant with summer savory and thyme. Avoid squash which competes for space.',
    varieties: [
      'Beauregard: Orange flesh, reliable and disease-resistant. Most widely grown commercial variety. 90-100 days. Excellent flavor and storage.',
      'Georgia Jet: Fastest-maturing sweet potato (90 days). Best for northern gardens with shorter seasons. Orange flesh, sweet flavor. Cold-tolerant.'
    ]),
  Plant(name: 'Swiss Chard', code: 'CHD', icon: '🥬', color: '#14b8a6', type: 'vegetable', plantAfterFrostDays: -14, startIndoorsWeeks: 0, harvestWeeks: 8, sqftSpacing: 2, lightLevel: 'low', supportsFall: true, fallPlantBeforeFrostDays: 60, fallStartIndoorsWeeks: 0,
    careInstructions: 'Cut-and-come-again green that produces all season. Harvest outer leaves when 6-8 inches, leaving center to continue growing. Very heat and cold tolerant. More forgiving than spinach. Both leaves and colorful stems are edible. Can produce from spring through fall.',
    watering: 'Regular water for tender leaves. Provide 1-1.5 inches per week. Can tolerate some drought.',
    soil: 'Rich soil with pH 6.0-7.0. Add compost before planting. Benefits from side-dressing with nitrogen.',
    companions: 'Plant with beans, brassicas, and onions. Avoid pole beans and cucumbers.',
    varieties: [
      'Fordhook Giant: Green leaves with white stems. Large, thick leaves. Very productive and heat-tolerant. 55-60 days.',
      'Bright Lights: Rainbow mix with stems in yellow, pink, red, orange, and white. Beautiful ornamental edible. 55 days. Cold-hardy.'
    ]),
  Plant(name: 'Thyme', code: 'THY', icon: '🌿', color: '#166534', type: 'herb', plantAfterFrostDays: 0, startIndoorsWeeks: 8, harvestWeeks: 52, sqftSpacing: 4, lightLevel: 'high',
    careInstructions: 'Hardy perennial herb (zones 5-9) with many varieties. Low-growing, spreading plant. Harvest stems before flowering. Cut back by one-third after flowering to maintain shape. Drought-tolerant once established. Divide every 3-4 years. Flavor intensifies when dried.',
    watering: 'Drought-tolerant once established. Water when soil is dry 2 inches down. Prefers drier conditions.',
    soil: 'Well-draining soil with pH 6.0-8.0. Tolerates poor, rocky soil. Excellent drainage essential.',
    companions: 'Plant with cabbage, tomatoes, and strawberries. Repels cabbage worms.',
    varieties: [
      'English Thyme: Most common culinary thyme. Small gray-green leaves, strong flavor. Upright growth to 12 inches. Hardy to zone 5.',
      'French Thyme: More refined flavor than English, preferred by chefs. Narrow gray leaves. Hardy to zone 6.'
    ]),
  Plant(name: 'Tomato', code: 'TOM', icon: '🍅', color: '#dc2626', type: 'fruit', plantAfterFrostDays: 10, startIndoorsWeeks: 6, harvestWeeks: 10, sqftSpacing: 1, cellsRequired: 2, lightLevel: 'high', tips: ['Provide support; prune indeterminates'], 
    careInstructions: 'Stake or cage plants for support. Pinch off suckers on indeterminate varieties to focus energy on fruit production. Mulch around plants to retain moisture and prevent soil-borne diseases. Remove lower leaves as plant grows to improve airflow.',
    watering: 'Water deeply and consistently, about 1-2 inches per week. Water at base of plant, not overhead. Inconsistent watering can lead to blossom end rot and fruit cracking.',
    soil: 'Rich, well-draining soil with pH 6.0-6.8. Add compost before planting. Side-dress with compost or balanced fertilizer every 3-4 weeks during growing season.',
    companions: 'Plant with basil, carrots, onions, and marigolds. Avoid planting near brassicas or fennel.',
    varieties: [
      'Cherry Tomatoes: Perfect for snacking and salads. Sweet 100 produces hundreds of 1-inch fruits with exceptional sweetness. Sungold is an early producer with golden-orange fruits that have a tropical, fruity flavor. Both are prolific and easy to grow.',
      'Slicing Tomatoes: Best for sandwiches and fresh eating. Brandywine is a beloved heirloom with large pink fruits and rich, complex flavor but needs longer season. Big Beef produces reliable 10oz fruits with excellent disease resistance, ideal for beginners.',
      'Paste Tomatoes: Ideal for sauces and canning due to low moisture and few seeds. Roma is compact and determinate (all fruit ripens at once), perfect for making sauce in batches. San Marzano has more authentic Italian flavor with longer fruits.',
      'Dwarf/Container Varieties: Great for small spaces and patio growing. Patio Princess stays under 2 feet but produces full-size fruits. Tiny Tim grows only 12 inches tall with marble-sized tomatoes, perfect for windowsills or hanging baskets.'
    ]),
  Plant(name: 'Tomatillo', code: 'TML', icon: '🟢', color: '#22c55e', type: 'fruit', plantAfterFrostDays: 10, startIndoorsWeeks: 6, harvestWeeks: 10, sqftSpacing: 1, cellsRequired: 2, lightLevel: 'high', tips: ['Grow at least two plants'],
    careInstructions: 'Mexican relative of tomato. Must grow at least 2 plants for cross-pollination. Fruit grows inside papery husk. Harvest when fruit fills and splits husk, turning from green to yellow-green. Remove sticky coating by washing. Easier to grow than tomatoes, very productive.',
    watering: 'Regular water when establishing, then moderate. Provide 1 inch per week. More drought-tolerant than tomatoes.',
    soil: 'Well-draining soil with pH 5.5-7.0. Moderate fertility - less fertilizer than tomatoes. Avoid over-fertilizing.',
    companions: 'Plant with basil, onions, and carrots. Avoid fennel and brassicas.',
    varieties: [
      'Toma Verde: Most popular variety with large (2-3 inch) green fruits. Productive and reliable. 60-70 days. Classic salsa verde tomatillo.',
      'Purple Tomatillo: Sweeter and fruitier than green types. Smaller fruits turn purple when ripe. 70-80 days. Great for fresh eating.'
    ]),
  Plant(name: 'Turnips', code: 'TUR', icon: '🟣', color: '#c084fc', type: 'vegetable', plantAfterFrostDays: -14, startIndoorsWeeks: 0, harvestWeeks: 7, sqftSpacing: 9, lightLevel: 'low', supportsFall: true, fallPlantBeforeFrostDays: 56, fallStartIndoorsWeeks: 0, tips: ['Greens and roots edible'],
    careInstructions: 'Fast-growing cool-season crop producing both edible roots and greens. Harvest baby turnips at 2 inches for tender roots. Can harvest greens separately without damaging roots. Best flavor in cool weather; hot weather makes roots woody and bitter. Fall crop superior to spring.',
    watering: 'Consistent moisture for tender, mild roots. Provide 1 inch per week. Stress causes woody, bitter flavor.',
    soil: 'Well-draining soil with pH 6.0-7.0. Light feeder. Add compost before planting.',
    companions: 'Plant with peas and onions. Avoid brassicas which share pests.',
    varieties: [
      'Purple Top White Globe: Classic turnip with purple shoulders and white bottom. Sweet, mild flavor. 50-60 days. Stores well.',
      'Hakurei: Japanese salad turnip with pure white roots. Very sweet and tender, can eat raw like an apple. Quick (35-40 days). Best harvested small.'
    ]),
  Plant(name: 'Watermelon', code: 'WAT', icon: '🍉', color: '#10b981', type: 'fruit', plantAfterFrostDays: 21, startIndoorsWeeks: 0, harvestWeeks: 14, sqftSpacing: 1, lightLevel: 'high', cellsRequired: 4,
    careInstructions: 'Heat-loving crop needing very warm soil (75°F+) and long season. Check ripeness by: dull (not shiny) skin, yellow ground spot where melon rested, dried brown tendril near stem, hollow sound when thumped. Reduce watering as fruits ripen for sweeter melons.',
    watering: 'Regular water during growth, 1-2 inches per week. Reduce watering 1-2 weeks before harvest to concentrate sugars.',
    soil: 'Well-draining, sandy soil with pH 6.0-7.0. Heavy feeder. Add compost before planting.',
    companions: 'Plant with radishes and nasturtiums. Avoid potatoes.',
    varieties: [
      'Sugar Baby: Small personal-sized melons (8-10 lbs) with dark green skin and sweet red flesh. Quick maturing (75-80 days) for a watermelon. Good for small gardens and short seasons.',
      'Crimson Sweet: Classic oblong watermelon (20-25 lbs) with striped rind. Very sweet red flesh. Disease resistant. 85 days. Reliable producer.',
      'Yellow Doll: Small (5-8 lbs) with yellow flesh. Very sweet and early (70 days). Good for cool climates.'
    ]),
  Plant(name: 'Zucchini', code: 'ZUC', icon: '🥒', color: '#4d7c0f', type: 'vegetable', plantAfterFrostDays: 10, startIndoorsWeeks: 0, harvestWeeks: 8, sqftSpacing: 1, lightLevel: 'high', cellsRequired: 2,
    careInstructions: 'Harvest zucchini when 6-8 inches long for best flavor and to encourage continued production. Check plants daily as fruits grow quickly. Remove any damaged or oversized fruits to maintain productivity.',
    watering: 'Water deeply once a week, providing 1-2 inches. Water at soil level to prevent powdery mildew on leaves. Mulch around plants to retain moisture.',
    soil: 'Rich, well-draining soil with pH 6.0-7.5. Mix in compost before planting. Side-dress with compost midseason.',
    companions: 'Grows well with beans, corn, and radishes. Avoid planting near potatoes.',
    varieties: [
      'Green Zucchini: Traditional varieties, most productive. Black Beauty is the classic dark green with smooth skin, heavy producer, best harvested at 6-8 inches. Dark Green has slightly lighter color with white flesh, very prolific and uniform fruits, excellent disease resistance.',
      'Yellow Summer Squash: Milder, sweeter flavor than green. Golden Zucchini has bright yellow color and buttery flavor, same shape as green varieties. Crookneck has curved neck and bumpy skin, nutty flavor, the bumps indicate tenderness (smooth skin means overgrown).',
      'Italian Heirloom: Costata Romanesco is ribbed Italian variety with alternating light and dark green stripes. Nutty, rich flavor superior to standard zucchini. Edible when young, or let grow large for stuffing. The golden flowers are prized for frying.',
      'Compact Bush Varieties: No sprawling vines needed. Patio Star produces full-size fruits on compact 2-3 foot plants, perfect for containers. Buckingham is ultra-compact (18-24 inches) bred specifically for pots, produces continuously with regular harvesting.'
    ]),
  Plant(name: 'Blueberry', code: 'BLU', icon: '🫐', color: '#3b82f6', type: 'fruit', plantAfterFrostDays: 0, startIndoorsWeeks: 0, harvestWeeks: 156, sqftSpacing: 1, cellsRequired: 4, lightLevel: 'high', tips: ['Requires acidic soil', 'Perennial; mulch'], supportsFall: false,
    careInstructions: 'Long-lived perennial requiring acidic soil (pH 4.5-5.5). Needs 2 varieties for cross-pollination. Takes 2-3 years to establish, full production in 6 years. Remove flowers first 2 years. Prune out old wood (3+ years). Heavy mulch with pine needles or wood chips. Netting needed to protect from birds.',
    watering: 'Consistent moisture especially during fruiting. Provide 1-2 inches per week. Shallow roots need regular water.',
    soil: 'Acidic soil (pH 4.5-5.5) is essential. Amend with sulfur and peat moss. Add pine needle mulch. Well-draining.',
    companions: 'Plant with azaleas and rhododendrons (similar soil needs). Keep lawn grass away.',
    varieties: [
      'Northblue: Dwarf highbush (2-3 feet) with large, sweet berries. Very cold-hardy (zone 3). Self-fertile but better with partner. 900 chill hours.',
      'Bluecrop: Most popular highbush variety. Large, firm berries. Cold-hardy to zone 4. Consistent producer. 800 chill hours.',
      'Patriot: Large berries with excellent flavor. Very cold-hardy (zone 3). Early ripening. Disease resistant. 800 chill hours.'
    ]),
  Plant(name: 'Raspberry', code: 'RSP', icon: '🍇', color: '#a21caf', type: 'fruit', plantAfterFrostDays: 0, startIndoorsWeeks: 0, harvestWeeks: 104, sqftSpacing: 1, cellsRequired: 4, lightLevel: 'high', tips: ['Provide trellis', 'Prune old canes'], supportsFall: false,
    careInstructions: 'Perennial producing for 15-20 years. Two types: summer-bearing (fruit on 2-year canes) and everbearing (fruit on 1-year canes). Spreads via underground runners. Needs support/trellis. Prune out fruited canes after harvest. Mulch to suppress weeds and retain moisture. Can be invasive.',
    watering: 'Consistent moisture during fruiting. Provide 1-2 inches per week. Drip irrigation ideal.',
    soil: 'Well-draining soil with pH 5.5-6.5. Add compost annually. Avoid areas where tomatoes, potatoes, or peppers grew.',
    companions: 'Plant with garlic and tansy. Avoid blackberries (share diseases).',
    varieties: [
      'Heritage: Everbearing with two crops - summer and fall. Very cold-hardy (zone 4). Disease resistant. Can mow all canes for fall-only crop.',
      'Caroline: Everbearing with large, sweet berries. More heat-tolerant. Cold-hardy to zone 4. Heavy fall crop.'
    ]),
  Plant(name: 'Grape', code: 'GRP', icon: '🍇', color: '#6d28d9', type: 'fruit', plantAfterFrostDays: 0, startIndoorsWeeks: 0, harvestWeeks: 156, sqftSpacing: 1, cellsRequired: 4, lightLevel: 'high', tips: ['Sturdy trellis', 'Prune annually'], supportsFall: false,
    careInstructions: 'Long-lived perennial (50+ years) requiring sturdy trellis. Takes 3 years to establish, full production year 4. Annual pruning in late winter is critical - remove 90% of previous year growth. Train to specific system (4-arm Kniffen, etc). Harvest when fully colored and sweet. Many varieties need chill hours.',
    watering: 'Deep, infrequent watering once established. Reduce water as fruit ripens. Drought-tolerant but better production with some water.',
    soil: 'Well-draining soil with pH 5.5-7.0. Deep roots. Moderate fertility - avoid excess nitrogen.',
    companions: 'Plant with hyssop and geraniums. Avoid cabbage family.',
    varieties: [
      'Concord: Classic blue-black grape. Very cold-hardy (zone 4). Strong grape flavor, best for juice and jelly. Slip-skin type. 150 days.',
      'Marquette: Cold-climate wine grape (zone 4). Small clusters, high sugar. Disease resistant. 115 days.'
    ]),
];
