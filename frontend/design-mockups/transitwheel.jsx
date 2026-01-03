import React, { useState } from 'react';

const TransitWheelWithInsights = () => {
    const [selectedPlanet, setSelectedPlanet] = useState(null);

    const signs = [
        { name: 'Aries', symbol: '♈', element: 'Fire', color: '#E84855' },
        { name: 'Taurus', symbol: '♉', element: 'Earth', color: '#00D4AA' },
        { name: 'Gemini', symbol: '♊', element: 'Air', color: '#7D67FE' },
        { name: 'Cancer', symbol: '♋', element: 'Water', color: '#00B4D8' },
        { name: 'Leo', symbol: '♌', element: 'Fire', color: '#FF8C42' },
        { name: 'Virgo', symbol: '♍', element: 'Earth', color: '#8B7355' },
        { name: 'Libra', symbol: '♎', element: 'Air', color: '#FF59D0' },
        { name: 'Scorpio', symbol: '♏', element: 'Water', color: '#9D4EDD' },
        { name: 'Sagittarius', symbol: '♐', element: 'Fire', color: '#E84855' },
        { name: 'Capricorn', symbol: '♑', element: 'Earth', color: '#6B7280' },
        { name: 'Aquarius', symbol: '♒', element: 'Air', color: '#00B4D8' },
        { name: 'Pisces', symbol: '♓', element: 'Water', color: '#7D67FE' },
    ];

    const houseThemes = {
        1: { name: 'Self & Identity', keyword: 'Identity' },
        2: { name: 'Money & Values', keyword: 'Resources' },
        3: { name: 'Communication & Mind', keyword: 'Communication' },
        4: { name: 'Home & Roots', keyword: 'Foundation' },
        5: { name: 'Creativity & Pleasure', keyword: 'Expression' },
        6: { name: 'Health & Service', keyword: 'Routine' },
        7: { name: 'Partnership & Others', keyword: 'Partnership' },
        8: { name: 'Transformation & Depth', keyword: 'Depths' },
        9: { name: 'Philosophy & Expansion', keyword: 'Expansion' },
        10: { name: 'Career & Public Image', keyword: 'Achievement' },
        11: { name: 'Community & Dreams', keyword: 'Community' },
        12: { name: 'Spirituality & Unconscious', keyword: 'Dissolution' },
    };

    // Combined natal + transit data for each planet
    const planets = [
        {
            id: 'sun',
            name: 'Sun',
            symbol: '☉',
            color: '#FAFF0E',
            natal: { sign: 'Aries', degree: 15.2, house: 5 },
            transit: { sign: 'Capricorn', degree: 9.6, house: 2 },
            status: 'gap',
            pull: "Your Sun shines through creative self-expression. Today it's being pulled toward material concerns and practical foundations.",
            feelings: ['Tension between play and responsibility', 'Creative blocks around money', 'Identity tied to productivity'],
            practice: "Create something today that has no practical purpose. Let joy exist without justification.",
        },
        {
            id: 'moon',
            name: 'Moon',
            symbol: '☽',
            color: '#C0C0C0',
            natal: { sign: 'Capricorn', degree: 22.4, house: 2 },
            transit: { sign: 'Taurus', degree: 22.1, house: 6 },
            status: 'resonance',
            pull: "Your emotional security and today's lunar energy both seek grounded stability. They speak the same language of comfort.",
            feelings: ['Emotionally settled', 'Body and feelings aligned', 'Practical self-care feels natural'],
            practice: "Lean into this harmony. Nourish yourself with something tangible—good food, soft textures, steady rhythms.",
        },
        {
            id: 'mercury',
            name: 'Mercury',
            symbol: '☿',
            color: '#00D4AA',
            natal: { sign: 'Aries', degree: 8.7, house: 5 },
            transit: { sign: 'Sagittarius', degree: 27.3, house: 1 },
            status: 'gap',
            pull: "Your mind naturally plays and creates. Today's Mercury wants big-picture philosophy and self-focused expression.",
            feelings: ['Thoughts scattered between fun and meaning', 'Restless mental energy', 'Wanting to speak your truth boldly'],
            practice: "Write down one big idea that excites you. Let your playful mind tackle something philosophical.",
        },
        {
            id: 'venus',
            name: 'Venus',
            symbol: '♀',
            color: '#FF59D0',
            natal: { sign: 'Taurus', degree: 3.1, house: 6 },
            transit: { sign: 'Aquarius', degree: 4.2, house: 3 },
            status: 'gap',
            pull: "Your love language is sensual and steady. Today's Venus craves intellectual connection and unconventional relating.",
            feelings: ['Torn between comfort and novelty', 'Conversations feel more exciting than touch', 'Valuing ideas over things'],
            practice: "Have a conversation that surprises you. Let connection be mental before it's physical.",
        },
        {
            id: 'mars',
            name: 'Mars',
            symbol: '♂',
            color: '#E84855',
            natal: { sign: 'Gemini', degree: 19.5, house: 7 },
            transit: { sign: 'Cancer', degree: 18.7, house: 8 },
            status: 'resonance',
            pull: "Your drive operates through partnership. Today's Mars adds emotional depth and transformative intensity to your actions.",
            feelings: ['Motivated by emotional bonds', 'Action feels purposeful and deep', 'Willing to go beneath the surface'],
            practice: "Channel this aligned energy into something that requires both courage and vulnerability.",
        },
        {
            id: 'jupiter',
            name: 'Jupiter',
            symbol: '♃',
            color: '#FF8C42',
            natal: { sign: 'Libra', degree: 14.8, house: 11 },
            transit: { sign: 'Gemini', degree: 11.4, house: 7, retrograde: true },
            status: 'gap',
            pull: "Your expansion comes through community and ideals. Today's Jupiter (retrograde) is reviewing how you grow through one-on-one connections.",
            feelings: ['Social vs intimate tension', 'Reconsidering what growth means', 'Old partnerships on your mind'],
            practice: "Reflect on one relationship that helped you grow. What did it teach you about balance?",
        },
        {
            id: 'saturn',
            name: 'Saturn',
            symbol: '♄',
            color: '#7D67FE',
            natal: { sign: 'Capricorn', degree: 28.9, house: 2 },
            transit: { sign: 'Pisces', degree: 24.1, house: 4 },
            status: 'gap',
            pull: "Your discipline builds material security. Today's Saturn asks you to structure your inner world, home, and emotional foundations.",
            feelings: ['Financial vs emotional security tension', 'Home needs attention', 'Boundaries around family'],
            practice: "Create one small structure at home—organize a space, set a boundary, establish a ritual.",
        },
        {
            id: 'uranus',
            name: 'Uranus',
            symbol: '♅',
            color: '#00B4D8',
            natal: { sign: 'Capricorn', degree: 12.3, house: 2 },
            transit: { sign: 'Taurus', degree: 23.5, house: 6, retrograde: true },
            status: 'resonance',
            pull: "Your need for material freedom echoes today's transit through daily routines. Both seek liberation through practical change.",
            feelings: ['Ready to break old habits', 'Body asking for something different', 'Values shifting naturally'],
            practice: "Change one daily routine. Small rebellion in service of authentic living.",
        },
        {
            id: 'neptune',
            name: 'Neptune',
            symbol: '♆',
            color: '#9D4EDD',
            natal: { sign: 'Scorpio', degree: 18.6, house: 8 },
            transit: { sign: 'Pisces', degree: 28.9, house: 12 },
            status: 'gap',
            pull: "Your Neptune transforms through intensity and depth. Today it's being pulled toward complete dissolution and spiritual surrender.",
            feelings: ['Boundaries dissolving', 'Vivid dreams or fantasies', 'Urge to escape or transcend', 'Creative or spiritual downloads'],
            practice: "Let the depths rise to the surface. Journal what wants to be released. Surrender something.",
        },
        {
            id: 'pluto',
            name: 'Pluto',
            symbol: '♇',
            color: '#6B7280',
            natal: { sign: 'Scorpio', degree: 22.1, house: 12 },
            transit: { sign: 'Aquarius', degree: 1.2, house: 3 },
            status: 'gap',
            pull: "Your power regenerates in solitude and the unconscious. Today's Pluto transforms through communication and collective ideas.",
            feelings: ['Private intensity meeting public discourse', 'Deep thoughts demanding expression', 'Power in words'],
            practice: "Speak one truth you usually keep hidden. Let your depths inform the conversation.",
        },
    ];

    // Calculate angle from sign and degree
    const getAngleFromPosition = (sign, degree) => {
        const signIndex = signs.findIndex(s => s.name === sign);
        return (signIndex * 30 + degree) - 90;
    };

    // Get position on wheel from angle and radius
    const getPositionOnWheel = (angle, radius) => {
        const radian = angle * (Math.PI / 180);
        return {
            x: Math.cos(radian) * radius,
            y: Math.sin(radian) * radius,
        };
    };

    // Generate arc path between two angles
    const getArcPath = (angle1, angle2, radius) => {
        // Normalize angles
        let start = angle1;
        let end = angle2;

        // Calculate the shortest arc direction
        let diff = end - start;
        if (diff > 180) diff -= 360;
        if (diff < -180) diff += 360;

        const startRad = (start * Math.PI) / 180;
        const endAngle = start + diff;
        const endRad = (endAngle * Math.PI) / 180;

        const x1 = 150 + Math.cos(startRad) * radius;
        const y1 = 150 + Math.sin(startRad) * radius;
        const x2 = 150 + Math.cos(endRad) * radius;
        const y2 = 150 + Math.sin(endRad) * radius;

        const largeArc = Math.abs(diff) > 180 ? 1 : 0;
        const sweep = diff > 0 ? 1 : 0;

        return `M ${x1} ${y1} A ${radius} ${radius} 0 ${largeArc} ${sweep} ${x2} ${y2}`;
    };

    const handlePlanetClick = (planet) => {
        if (selectedPlanet?.id === planet.id) {
            setSelectedPlanet(null);
        } else {
            setSelectedPlanet(planet);
        }
    };

    const selectedNatalAngle = selectedPlanet ? getAngleFromPosition(selectedPlanet.natal.sign, selectedPlanet.natal.degree) : 0;
    const selectedTransitAngle = selectedPlanet ? getAngleFromPosition(selectedPlanet.transit.sign, selectedPlanet.transit.degree) : 0;

    const gapCount = planets.filter(p => p.status === 'gap').length;
    const resonanceCount = planets.filter(p => p.status === 'resonance').length;

    return (
        <div style={{
            background: 'linear-gradient(180deg, #0A0A0F 0%, #0D0D15 100%)',
            minHeight: '100vh',
            fontFamily: "'Syne', sans-serif",
            color: '#FFFFFF',
            padding: '20px',
        }}>
            <style>{`
        @import url('https://fonts.googleapis.com/css2?family=Syne:wght@400;500;600;700;800&family=Space+Grotesk:wght@300;400;500&display=swap');
        
        @keyframes rotateRing {
          from { transform: rotate(0deg); }
          to { transform: rotate(360deg); }
        }
        
        @keyframes pulse {
          0%, 100% { opacity: 0.5; }
          50% { opacity: 1; }
        }
        
        @keyframes gapPulse {
          0%, 100% { stroke-opacity: 0.4; stroke-dashoffset: 0; }
          50% { stroke-opacity: 0.9; stroke-dashoffset: 8; }
        }
        
        @keyframes resonanceGlow {
          0%, 100% { stroke-opacity: 0.6; filter: drop-shadow(0 0 4px currentColor); }
          50% { stroke-opacity: 1; filter: drop-shadow(0 0 12px currentColor); }
        }
        
        @keyframes ghostFloat {
          0%, 100% { transform: translate(0, 0); opacity: 0.7; }
          50% { transform: translate(0, -3px); opacity: 0.9; }
        }
        
        @keyframes slideUp {
          from { transform: translateY(30px); opacity: 0; }
          to { transform: translateY(0); opacity: 1; }
        }
        
        @keyframes retroPulse {
          0%, 100% { box-shadow: 0 0 8px #E84855; }
          50% { box-shadow: 0 0 16px #E84855; }
        }
        
        .planet-node {
          cursor: pointer;
          transition: all 0.2s ease;
        }
        
        .planet-node:hover {
          transform: scale(1.15);
        }
        
        .ghost-orb {
          animation: ghostFloat 3s ease-in-out infinite;
        }
        
        .gap-arc {
          animation: gapPulse 2s ease-in-out infinite;
        }
        
        .resonance-arc {
          animation: resonanceGlow 2.5s ease-in-out infinite;
        }
        
        .insight-card {
          animation: slideUp 0.3s ease-out;
        }
        
        .retrograde-badge {
          animation: retroPulse 2s ease-in-out infinite;
        }
      `}</style>

            {/* Header */}
            <div style={{
                display: 'flex',
                justifyContent: 'space-between',
                alignItems: 'center',
                marginBottom: '20px',
            }}>
                <div>
                    <h2 style={{ fontSize: '20px', fontWeight: 800, margin: 0 }}>Transit Alignment</h2>
                    <p style={{
                        fontSize: '12px',
                        color: 'rgba(255,255,255,0.5)',
                        margin: '4px 0 0 0',
                        fontFamily: "'Space Grotesk', sans-serif",
                    }}>Your chart vs. today's sky</p>
                </div>
                <div style={{ display: 'flex', gap: '8px' }}>
                    <div style={{
                        background: 'rgba(232, 72, 85, 0.15)',
                        borderRadius: '12px',
                        padding: '6px 12px',
                        display: 'flex',
                        alignItems: 'center',
                        gap: '6px',
                    }}>
                        <div style={{ width: '8px', height: '8px', borderRadius: '50%', background: '#E84855' }} />
                        <span style={{ fontSize: '12px', color: '#E84855', fontWeight: 600 }}>{gapCount} Gaps</span>
                    </div>
                    <div style={{
                        background: 'rgba(0, 212, 170, 0.15)',
                        borderRadius: '12px',
                        padding: '6px 12px',
                        display: 'flex',
                        alignItems: 'center',
                        gap: '6px',
                    }}>
                        <div style={{ width: '8px', height: '8px', borderRadius: '50%', background: '#00D4AA' }} />
                        <span style={{ fontSize: '12px', color: '#00D4AA', fontWeight: 600 }}>{resonanceCount} Resonances</span>
                    </div>
                </div>
            </div>

            {/* Chart Wheel */}
            <div style={{
                position: 'relative',
                width: '320px',
                height: '320px',
                margin: '0 auto 24px',
            }}>
                <svg
                    width="320"
                    height="320"
                    viewBox="0 0 300 300"
                    style={{ position: 'absolute', top: 0, left: 0, width: '100%', height: '100%' }}
                >
                    {/* Background circles */}
                    <circle cx="150" cy="150" r="145" fill="none" stroke="rgba(255,255,255,0.03)" strokeWidth="1" />
                    <circle cx="150" cy="150" r="120" fill="none" stroke="rgba(255,255,255,0.06)" strokeWidth="1" />
                    <circle cx="150" cy="150" r="85" fill="none" stroke="rgba(255,255,255,0.04)" strokeWidth="1" strokeDasharray="2 4" />
                    <circle cx="150" cy="150" r="55" fill="none" stroke="rgba(255,255,255,0.03)" strokeWidth="1" />
                    <circle cx="150" cy="150" r="35" fill="rgba(255,255,255,0.02)" stroke="rgba(255,255,255,0.06)" strokeWidth="1" />

                    {/* House divider lines */}
                    {[...Array(12)].map((_, i) => {
                        const angle = (i * 30 - 90) * (Math.PI / 180);
                        const x1 = 150 + Math.cos(angle) * 35;
                        const y1 = 150 + Math.sin(angle) * 35;
                        const x2 = 150 + Math.cos(angle) * 120;
                        const y2 = 150 + Math.sin(angle) * 120;
                        return (
                            <line
                                key={i}
                                x1={x1} y1={y1} x2={x2} y2={y2}
                                stroke="rgba(255,255,255,0.06)"
                                strokeWidth="1"
                            />
                        );
                    })}

                    {/* House numbers */}
                    {[...Array(12)].map((_, i) => {
                        const midAngle = (i * 30 + 15 - 90) * (Math.PI / 180);
                        const x = 150 + Math.cos(midAngle) * 45;
                        const y = 150 + Math.sin(midAngle) * 45;
                        return (
                            <text
                                key={i}
                                x={x}
                                y={y}
                                fill="rgba(255,255,255,0.2)"
                                fontSize="10"
                                textAnchor="middle"
                                dominantBaseline="middle"
                                fontFamily="Space Grotesk"
                            >
                                {i + 1}
                            </text>
                        );
                    })}

                    {/* Sign symbols on outer ring */}
                    {signs.map((sign, i) => {
                        const midAngle = i * 30 + 15 - 90;
                        const pos = getPositionOnWheel(midAngle, 132);
                        return (
                            <text
                                key={sign.name}
                                x={150 + pos.x}
                                y={150 + pos.y}
                                fill={sign.color}
                                fontSize="12"
                                textAnchor="middle"
                                dominantBaseline="middle"
                                opacity="0.6"
                            >
                                {sign.symbol}
                            </text>
                        );
                    })}

                    {/* Gap/Resonance Arc - only when planet selected */}
                    {selectedPlanet && (
                        <path
                            d={getArcPath(selectedNatalAngle, selectedTransitAngle, 85)}
                            fill="none"
                            stroke={selectedPlanet.status === 'gap' ? '#E84855' : '#00D4AA'}
                            strokeWidth={selectedPlanet.status === 'gap' ? 3 : 4}
                            strokeLinecap="round"
                            strokeDasharray={selectedPlanet.status === 'gap' ? '8 6' : 'none'}
                            className={selectedPlanet.status === 'gap' ? 'gap-arc' : 'resonance-arc'}
                            style={{ color: selectedPlanet.status === 'gap' ? '#E84855' : '#00D4AA' }}
                        />
                    )}

                    {/* Gradient definitions */}
                    <defs>
                        <filter id="glow" x="-50%" y="-50%" width="200%" height="200%">
                            <feGaussianBlur stdDeviation="2" result="coloredBlur" />
                            <feMerge>
                                <feMergeNode in="coloredBlur" />
                                <feMergeNode in="SourceGraphic" />
                            </feMerge>
                        </filter>
                    </defs>
                </svg>

                {/* Center info */}
                <div style={{
                    position: 'absolute',
                    top: '50%',
                    left: '50%',
                    transform: 'translate(-50%, -50%)',
                    width: '60px',
                    height: '60px',
                    borderRadius: '50%',
                    display: 'flex',
                    flexDirection: 'column',
                    alignItems: 'center',
                    justifyContent: 'center',
                    textAlign: 'center',
                }}>
                    {selectedPlanet ? (
                        <>
                            <span style={{
                                fontSize: '22px',
                                color: selectedPlanet.color,
                            }}>{selectedPlanet.symbol}</span>
                            <span style={{
                                fontSize: '8px',
                                color: selectedPlanet.status === 'gap' ? '#E84855' : '#00D4AA',
                                fontWeight: 700,
                                textTransform: 'uppercase',
                                letterSpacing: '1px',
                            }}>{selectedPlanet.status}</span>
                        </>
                    ) : (
                        <span style={{
                            fontSize: '9px',
                            color: 'rgba(255,255,255,0.3)',
                            lineHeight: '1.3',
                        }}>TAP A<br />PLANET</span>
                    )}
                </div>

                {/* Natal ghost orb - only when planet selected */}
                {selectedPlanet && (() => {
                    const natalPos = getPositionOnWheel(selectedNatalAngle, 85);
                    return (
                        <div
                            className="ghost-orb"
                            style={{
                                position: 'absolute',
                                left: `calc(50% + ${natalPos.x * (320 / 300)}px - 14px)`,
                                top: `calc(50% + ${natalPos.y * (320 / 300)}px - 14px)`,
                                width: '28px',
                                height: '28px',
                                borderRadius: '50%',
                                background: `radial-gradient(circle, ${selectedPlanet.color}30 0%, transparent 70%)`,
                                border: `2px dashed ${selectedPlanet.color}60`,
                                display: 'flex',
                                alignItems: 'center',
                                justifyContent: 'center',
                                zIndex: 5,
                            }}
                        >
                            <span style={{ fontSize: '12px', color: selectedPlanet.color, opacity: 0.8 }}>
                                {selectedPlanet.symbol}
                            </span>
                            {/* "YOU" label */}
                            <div style={{
                                position: 'absolute',
                                bottom: '-18px',
                                left: '50%',
                                transform: 'translateX(-50%)',
                                fontSize: '8px',
                                color: selectedPlanet.color,
                                fontWeight: 700,
                                letterSpacing: '1px',
                                whiteSpace: 'nowrap',
                            }}>YOU</div>
                        </div>
                    );
                })()}

                {/* Transit planet nodes */}
                {planets.map((planet) => {
                    const angle = getAngleFromPosition(planet.transit.sign, planet.transit.degree);
                    const pos = getPositionOnWheel(angle, 100);
                    const isSelected = selectedPlanet?.id === planet.id;
                    const isRetrograde = planet.transit.retrograde;

                    return (
                        <div
                            key={planet.id}
                            className="planet-node"
                            onClick={() => handlePlanetClick(planet)}
                            style={{
                                position: 'absolute',
                                left: `calc(50% + ${pos.x * (320 / 300)}px - 16px)`,
                                top: `calc(50% + ${pos.y * (320 / 300)}px - 16px)`,
                                width: '32px',
                                height: '32px',
                                borderRadius: '50%',
                                background: isSelected
                                    ? `linear-gradient(135deg, ${planet.color} 0%, ${planet.color}80 100%)`
                                    : `linear-gradient(135deg, ${planet.color}20 0%, ${planet.color}08 100%)`,
                                border: `2px solid ${isSelected ? planet.color : planet.color + '40'}`,
                                display: 'flex',
                                alignItems: 'center',
                                justifyContent: 'center',
                                boxShadow: isSelected ? `0 0 20px ${planet.color}50` : 'none',
                                zIndex: isSelected ? 10 : 1,
                                transition: 'all 0.2s ease',
                            }}
                        >
                            <span style={{
                                fontSize: '14px',
                                color: isSelected ? '#0A0A0F' : planet.color,
                            }}>{planet.symbol}</span>

                            {/* Retrograde badge */}
                            {isRetrograde && (
                                <div
                                    className={isSelected ? '' : 'retrograde-badge'}
                                    style={{
                                        position: 'absolute',
                                        top: '-4px',
                                        right: '-4px',
                                        width: '14px',
                                        height: '14px',
                                        borderRadius: '50%',
                                        background: '#E84855',
                                        border: '2px solid #0A0A0F',
                                        display: 'flex',
                                        alignItems: 'center',
                                        justifyContent: 'center',
                                        fontSize: '8px',
                                        color: 'white',
                                        fontWeight: 700,
                                    }}>℞</div>
                            )}

                            {/* SKY label for selected */}
                            {isSelected && (
                                <div style={{
                                    position: 'absolute',
                                    bottom: '-18px',
                                    left: '50%',
                                    transform: 'translateX(-50%)',
                                    fontSize: '8px',
                                    color: planet.color,
                                    fontWeight: 700,
                                    letterSpacing: '1px',
                                    whiteSpace: 'nowrap',
                                }}>SKY</div>
                            )}
                        </div>
                    );
                })}
            </div>

            {/* Planet Pills - Quick Select */}
            <div style={{
                display: 'flex',
                flexWrap: 'wrap',
                gap: '6px',
                justifyContent: 'center',
                marginBottom: '24px',
            }}>
                {planets.map((planet) => {
                    const isSelected = selectedPlanet?.id === planet.id;
                    return (
                        <button
                            key={planet.id}
                            onClick={() => handlePlanetClick(planet)}
                            style={{
                                background: isSelected
                                    ? `linear-gradient(135deg, ${planet.color} 0%, ${planet.color}80 100%)`
                                    : 'rgba(255,255,255,0.04)',
                                border: `1px solid ${isSelected ? planet.color : 'rgba(255,255,255,0.1)'}`,
                                borderRadius: '16px',
                                padding: '6px 12px',
                                cursor: 'pointer',
                                display: 'flex',
                                alignItems: 'center',
                                gap: '6px',
                            }}
                        >
                            <span style={{
                                fontSize: '12px',
                                color: isSelected ? '#0A0A0F' : planet.color
                            }}>{planet.symbol}</span>
                            <div style={{
                                width: '6px',
                                height: '6px',
                                borderRadius: '50%',
                                background: planet.status === 'gap' ? '#E84855' : '#00D4AA',
                                opacity: isSelected ? 1 : 0.6,
                            }} />
                        </button>
                    );
                })}
            </div>

            {/* Insight Card Area */}
            <div style={{
                minHeight: '300px',
            }}>
                {selectedPlanet ? (
                    <div
                        className="insight-card"
                        style={{
                            background: 'rgba(255, 255, 255, 0.03)',
                            borderRadius: '24px',
                            border: '1px solid rgba(255, 255, 255, 0.08)',
                            overflow: 'hidden',
                        }}
                    >
                        {/* Card Header */}
                        <div style={{
                            padding: '20px',
                            borderBottom: '1px solid rgba(255, 255, 255, 0.06)',
                            display: 'flex',
                            justifyContent: 'space-between',
                            alignItems: 'center',
                        }}>
                            <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
                                <div style={{
                                    width: '48px',
                                    height: '48px',
                                    borderRadius: '50%',
                                    background: `linear-gradient(135deg, ${selectedPlanet.color}30 0%, ${selectedPlanet.color}10 100%)`,
                                    border: `2px solid ${selectedPlanet.color}50`,
                                    display: 'flex',
                                    alignItems: 'center',
                                    justifyContent: 'center',
                                }}>
                                    <span style={{ fontSize: '24px', color: selectedPlanet.color }}>{selectedPlanet.symbol}</span>
                                </div>
                                <div>
                                    <h3 style={{ fontSize: '18px', fontWeight: 700, margin: 0 }}>{selectedPlanet.name}</h3>
                                    <p style={{
                                        fontSize: '12px',
                                        color: 'rgba(255,255,255,0.5)',
                                        margin: '2px 0 0 0',
                                        fontFamily: "'Space Grotesk', sans-serif",
                                    }}>
                                        {selectedPlanet.natal.house}{getOrdinal(selectedPlanet.natal.house)} → {selectedPlanet.transit.house}{getOrdinal(selectedPlanet.transit.house)} House
                                    </p>
                                </div>
                            </div>
                            <div style={{
                                background: selectedPlanet.status === 'gap'
                                    ? 'rgba(232, 72, 85, 0.15)'
                                    : 'rgba(0, 212, 170, 0.15)',
                                border: `1px solid ${selectedPlanet.status === 'gap' ? '#E84855' : '#00D4AA'}40`,
                                borderRadius: '12px',
                                padding: '6px 14px',
                            }}>
                                <span style={{
                                    fontSize: '12px',
                                    fontWeight: 700,
                                    color: selectedPlanet.status === 'gap' ? '#E84855' : '#00D4AA',
                                    textTransform: 'uppercase',
                                    letterSpacing: '1px',
                                }}>{selectedPlanet.status}</span>
                            </div>
                        </div>

                        {/* YOURS vs TODAY */}
                        <div style={{
                            display: 'grid',
                            gridTemplateColumns: '1fr 1fr',
                            borderBottom: '1px solid rgba(255, 255, 255, 0.06)',
                        }}>
                            <div style={{
                                padding: '16px 20px',
                                borderRight: '1px solid rgba(255, 255, 255, 0.06)',
                            }}>
                                <p style={{
                                    fontSize: '10px',
                                    color: 'rgba(255,255,255,0.4)',
                                    margin: '0 0 8px 0',
                                    textTransform: 'uppercase',
                                    letterSpacing: '1.5px',
                                    fontFamily: "'Space Grotesk', sans-serif",
                                }}>Yours</p>
                                <p style={{
                                    fontSize: '15px',
                                    fontWeight: 600,
                                    margin: '0 0 4px 0',
                                    color: selectedPlanet.color,
                                }}>{selectedPlanet.natal.sign}</p>
                                <p style={{
                                    fontSize: '12px',
                                    color: 'rgba(255,255,255,0.6)',
                                    margin: 0,
                                    fontFamily: "'Space Grotesk', sans-serif",
                                }}>{houseThemes[selectedPlanet.natal.house].keyword}</p>
                            </div>
                            <div style={{ padding: '16px 20px' }}>
                                <p style={{
                                    fontSize: '10px',
                                    color: 'rgba(255,255,255,0.4)',
                                    margin: '0 0 8px 0',
                                    textTransform: 'uppercase',
                                    letterSpacing: '1.5px',
                                    fontFamily: "'Space Grotesk', sans-serif",
                                }}>Today</p>
                                <p style={{
                                    fontSize: '15px',
                                    fontWeight: 600,
                                    margin: '0 0 4px 0',
                                    color: 'rgba(255,255,255,0.9)',
                                }}>{selectedPlanet.transit.sign}</p>
                                <p style={{
                                    fontSize: '12px',
                                    color: 'rgba(255,255,255,0.6)',
                                    margin: 0,
                                    fontFamily: "'Space Grotesk', sans-serif",
                                }}>{houseThemes[selectedPlanet.transit.house].keyword}</p>
                            </div>
                        </div>

                        {/* THE PULL */}
                        <div style={{
                            padding: '20px',
                            borderBottom: '1px solid rgba(255, 255, 255, 0.06)',
                        }}>
                            <p style={{
                                fontSize: '10px',
                                color: selectedPlanet.status === 'gap' ? '#E84855' : '#00D4AA',
                                margin: '0 0 10px 0',
                                textTransform: 'uppercase',
                                letterSpacing: '1.5px',
                                fontWeight: 600,
                            }}>{selectedPlanet.status === 'gap' ? 'The Pull' : 'The Harmony'}</p>
                            <p style={{
                                fontSize: '14px',
                                color: 'rgba(255,255,255,0.8)',
                                margin: 0,
                                lineHeight: '1.6',
                                fontFamily: "'Space Grotesk', sans-serif",
                            }}>{selectedPlanet.pull}</p>
                        </div>

                        {/* YOU MIGHT FEEL */}
                        <div style={{
                            padding: '20px',
                            borderBottom: '1px solid rgba(255, 255, 255, 0.06)',
                        }}>
                            <p style={{
                                fontSize: '10px',
                                color: 'rgba(255,255,255,0.4)',
                                margin: '0 0 12px 0',
                                textTransform: 'uppercase',
                                letterSpacing: '1.5px',
                                fontFamily: "'Space Grotesk', sans-serif",
                            }}>You Might Feel</p>
                            <div style={{ display: 'flex', flexWrap: 'wrap', gap: '8px' }}>
                                {selectedPlanet.feelings.map((feeling, i) => (
                                    <span
                                        key={i}
                                        style={{
                                            fontSize: '12px',
                                            color: 'rgba(255,255,255,0.7)',
                                            background: 'rgba(255,255,255,0.05)',
                                            padding: '6px 12px',
                                            borderRadius: '20px',
                                            fontFamily: "'Space Grotesk', sans-serif",
                                        }}
                                    >{feeling}</span>
                                ))}
                            </div>
                        </div>

                        {/* TODAY'S PRACTICE */}
                        <div style={{
                            padding: '20px',
                            background: selectedPlanet.status === 'gap'
                                ? 'rgba(232, 72, 85, 0.05)'
                                : 'rgba(0, 212, 170, 0.05)',
                        }}>
                            <p style={{
                                fontSize: '10px',
                                color: selectedPlanet.status === 'gap' ? '#E84855' : '#00D4AA',
                                margin: '0 0 10px 0',
                                textTransform: 'uppercase',
                                letterSpacing: '1.5px',
                                fontWeight: 600,
                            }}>Today's Practice</p>
                            <p style={{
                                fontSize: '14px',
                                color: 'rgba(255,255,255,0.9)',
                                margin: 0,
                                lineHeight: '1.6',
                                fontStyle: 'italic',
                                fontFamily: "'Space Grotesk', sans-serif",
                            }}>"{selectedPlanet.practice}"</p>
                        </div>
                    </div>
                ) : (
                    /* Default prompt state */
                    <div style={{
                        background: 'rgba(255, 255, 255, 0.02)',
                        borderRadius: '24px',
                        border: '1px dashed rgba(255, 255, 255, 0.1)',
                        padding: '48px 24px',
                        textAlign: 'center',
                    }}>
                        <div style={{
                            width: '64px',
                            height: '64px',
                            borderRadius: '50%',
                            background: 'rgba(255, 255, 255, 0.03)',
                            border: '1px solid rgba(255, 255, 255, 0.08)',
                            display: 'flex',
                            alignItems: 'center',
                            justifyContent: 'center',
                            margin: '0 auto 16px',
                        }}>
                            <span style={{ fontSize: '24px', opacity: 0.4 }}>☍</span>
                        </div>
                        <p style={{
                            fontSize: '16px',
                            fontWeight: 600,
                            color: 'rgba(255,255,255,0.5)',
                            margin: '0 0 8px 0',
                        }}>Tap a planet to see your alignment</p>
                        <p style={{
                            fontSize: '13px',
                            color: 'rgba(255,255,255,0.3)',
                            margin: 0,
                            fontFamily: "'Space Grotesk', sans-serif",
                        }}>Compare your birth chart with today's sky</p>
                    </div>
                )}
            </div>
        </div>
    );
};

// Helper function for ordinal suffixes
function getOrdinal(n) {
    const s = ['th', 'st', 'nd', 'rd'];
    const v = n % 100;
    return s[(v - 20) % 10] || s[v] || s[0];
}

export default TransitWheelWithInsights;