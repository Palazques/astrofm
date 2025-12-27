import React, { useState } from 'react';

const BirthChartWheel = () => {
    const [selectedPlanet, setSelectedPlanet] = useState(null);
    const [playingPlanet, setPlayingPlanet] = useState(null);
    const [playingAspect, setPlayingAspect] = useState(null);

    // Aspect types with colors and audio character
    const aspectTypes = {
        conjunction: { name: 'Conjunct', symbol: '☌', color: '#FAFF0E', harmony: 'blend', dash: null },
        sextile: { name: 'Sextile', symbol: '⚹', color: '#7D67FE', harmony: 'harmonious', dash: null },
        square: { name: 'Square', symbol: '□', color: '#E84855', harmony: 'tense', dash: '4,4' },
        trine: { name: 'Trine', symbol: '△', color: '#00D4AA', harmony: 'harmonious', dash: null },
        opposition: { name: 'Opposition', symbol: '☍', color: '#FF59D0', harmony: 'tense', dash: '8,4' },
    };

    const planets = [
        { id: 'sun', name: 'Sun', symbol: '☉', sign: 'Aries', house: 5, intensity: 85, frequency: 126, color: '#FAFF0E', angle: 135 },
        { id: 'moon', name: 'Moon', symbol: '☽', sign: 'Capricorn', house: 2, intensity: 80, frequency: 210, color: '#C0C0C0', angle: 45 },
        { id: 'mercury', name: 'Mercury', symbol: '☿', sign: 'Aries', house: 5, intensity: 44, frequency: 141, color: '#50E3C2', angle: 145 },
        { id: 'venus', name: 'Venus', symbol: '♀', sign: 'Aries', house: 5, intensity: 76, frequency: 221, color: '#FF59D0', angle: 125 },
        { id: 'mars', name: 'Mars', symbol: '♂', sign: 'Gemini', house: 7, intensity: 94, frequency: 145, color: '#E84855', angle: 195 },
        { id: 'jupiter', name: 'Jupiter', symbol: '♃', sign: 'Gemini', house: 7, intensity: 32, frequency: 184, color: '#FF8C42', angle: 210 },
        { id: 'saturn', name: 'Saturn', symbol: '♄', sign: 'Capricorn', house: 2, intensity: 99, frequency: 148, color: '#8B7355', angle: 55 },
        { id: 'uranus', name: 'Uranus', symbol: '♅', sign: 'Capricorn', house: 2, intensity: 53, frequency: 207, color: '#00D4AA', angle: 35 },
        { id: 'neptune', name: 'Neptune', symbol: '♆', sign: 'Capricorn', house: 2, intensity: 96, frequency: 211, color: '#7D67FE', angle: 65 },
        { id: 'pluto', name: 'Pluto', symbol: '♇', sign: 'Scorpio', house: 12, intensity: 100, frequency: 140, color: '#9B59B6', angle: 345 },
    ];

    const signs = [
        { name: 'Aries', element: 'Fire', color: '#E84855' },
        { name: 'Taurus', element: 'Earth', color: '#8B7355' },
        { name: 'Gemini', element: 'Air', color: '#7D67FE' },
        { name: 'Cancer', element: 'Water', color: '#00D4AA' },
        { name: 'Leo', element: 'Fire', color: '#FF8C42' },
        { name: 'Virgo', element: 'Earth', color: '#8B7355' },
        { name: 'Libra', element: 'Air', color: '#7D67FE' },
        { name: 'Scorpio', element: 'Water', color: '#9B59B6' },
        { name: 'Sagittarius', element: 'Fire', color: '#E84855' },
        { name: 'Capricorn', element: 'Earth', color: '#8B7355' },
        { name: 'Aquarius', element: 'Air', color: '#00D4AA' },
        { name: 'Pisces', element: 'Water', color: '#00D4AA' },
    ];

    // Custom SVG zodiac icons - modern thin-stroke geometric style
    const zodiacIcons = {
        Aries: (color) => (
            <svg viewBox="0 0 24 24" fill="none" stroke={color} strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round">
                <path d="M12 20V6" />
                <path d="M12 6C12 6 12 3 9 3C6 3 5 5 5 7C5 9 7 10 7 10" />
                <path d="M12 6C12 6 12 3 15 3C18 3 19 5 19 7C19 9 17 10 17 10" />
            </svg>
        ),
        Taurus: (color) => (
            <svg viewBox="0 0 24 24" fill="none" stroke={color} strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round">
                <circle cx="12" cy="15" r="6" />
                <path d="M6 6C6 6 6 9 9 9" />
                <path d="M18 6C18 6 18 9 15 9" />
                <path d="M9 9C9 9 9 9 12 9C15 9 15 9 15 9" />
            </svg>
        ),
        Gemini: (color) => (
            <svg viewBox="0 0 24 24" fill="none" stroke={color} strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round">
                <path d="M6 4H18" />
                <path d="M6 20H18" />
                <path d="M9 4V20" />
                <path d="M15 4V20" />
            </svg>
        ),
        Cancer: (color) => (
            <svg viewBox="0 0 24 24" fill="none" stroke={color} strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round">
                <path d="M19 8C19 8 19 5 16 5C13 5 13 8 13 8C13 8 13 11 16 11" />
                <path d="M5 16C5 16 5 19 8 19C11 19 11 16 11 16C11 16 11 13 8 13" />
                <path d="M16 11H8" />
                <path d="M8 13H16" />
            </svg>
        ),
        Leo: (color) => (
            <svg viewBox="0 0 24 24" fill="none" stroke={color} strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round">
                <circle cx="9" cy="9" r="4" />
                <path d="M13 9C13 9 15 9 17 11C19 13 19 17 17 19C15 21 13 19 13 17C13 15 15 15 15 15" />
            </svg>
        ),
        Virgo: (color) => (
            <svg viewBox="0 0 24 24" fill="none" stroke={color} strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round">
                <path d="M5 4V16C5 16 5 20 9 20" />
                <path d="M5 10C5 10 5 6 9 6C13 6 9 14 9 14C9 14 9 10 13 10C17 10 13 18 13 18" />
                <path d="M17 4V16" />
                <path d="M17 16C17 16 17 20 21 18" />
                <path d="M19 14L21 12" />
            </svg>
        ),
        Libra: (color) => (
            <svg viewBox="0 0 24 24" fill="none" stroke={color} strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round">
                <path d="M5 17H19" />
                <path d="M5 20H19" />
                <path d="M12 17V10" />
                <path d="M7 10C7 7 9 5 12 5C15 5 17 7 17 10" />
            </svg>
        ),
        Scorpio: (color) => (
            <svg viewBox="0 0 24 24" fill="none" stroke={color} strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round">
                <path d="M4 4V16C4 16 4 20 8 20" />
                <path d="M4 10C4 10 4 6 8 6C12 6 8 14 8 14C8 14 8 10 12 10C16 10 12 18 12 18" />
                <path d="M16 4V18C16 18 16 20 19 20" />
                <path d="M19 20L21 18" />
                <path d="M19 20L21 22" />
            </svg>
        ),
        Sagittarius: (color) => (
            <svg viewBox="0 0 24 24" fill="none" stroke={color} strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round">
                <path d="M5 19L19 5" />
                <path d="M19 5H13" />
                <path d="M19 5V11" />
                <path d="M9 9L15 15" />
            </svg>
        ),
        Capricorn: (color) => (
            <svg viewBox="0 0 24 24" fill="none" stroke={color} strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round">
                <path d="M6 4V12C6 12 6 16 10 16C14 16 14 12 14 12V8" />
                <path d="M10 16C10 16 10 20 14 20C18 20 18 16 18 16C18 16 18 12 14 14" />
                <circle cx="18" cy="18" r="2" />
            </svg>
        ),
        Aquarius: (color) => (
            <svg viewBox="0 0 24 24" fill="none" stroke={color} strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round">
                <path d="M4 9L7 6L10 9L13 6L16 9L19 6" />
                <path d="M4 15L7 12L10 15L13 12L16 15L19 12" />
            </svg>
        ),
        Pisces: (color) => (
            <svg viewBox="0 0 24 24" fill="none" stroke={color} strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round">
                <path d="M5 4C5 4 9 8 9 12C9 16 5 20 5 20" />
                <path d="M19 4C19 4 15 8 15 12C15 16 19 20 19 20" />
                <path d="M5 12H19" />
            </svg>
        ),
    };

    // Aspects between planets (based on angular relationships)
    const aspects = [
        // Sun aspects
        { planet1: 'sun', planet2: 'mercury', type: 'conjunction', orb: 5 },
        { planet1: 'sun', planet2: 'venus', type: 'conjunction', orb: 8 },
        { planet1: 'sun', planet2: 'mars', type: 'sextile', orb: 4 },
        { planet1: 'sun', planet2: 'jupiter', type: 'sextile', orb: 6 },
        { planet1: 'sun', planet2: 'moon', type: 'square', orb: 3 },
        // Moon aspects
        { planet1: 'moon', planet2: 'saturn', type: 'conjunction', orb: 6 },
        { planet1: 'moon', planet2: 'uranus', type: 'conjunction', orb: 8 },
        { planet1: 'moon', planet2: 'neptune', type: 'conjunction', orb: 5 },
        { planet1: 'moon', planet2: 'pluto', type: 'sextile', orb: 4 },
        // Mars aspects
        { planet1: 'mars', planet2: 'jupiter', type: 'conjunction', orb: 7 },
        { planet1: 'mars', planet2: 'saturn', type: 'opposition', orb: 5 },
        { planet1: 'mars', planet2: 'pluto', type: 'trine', orb: 3 },
        // Venus aspects
        { planet1: 'venus', planet2: 'mercury', type: 'conjunction', orb: 4 },
        { planet1: 'venus', planet2: 'jupiter', type: 'sextile', orb: 6 },
        // Saturn aspects
        { planet1: 'saturn', planet2: 'uranus', type: 'conjunction', orb: 5 },
        { planet1: 'saturn', planet2: 'neptune', type: 'conjunction', orb: 4 },
        // Uranus aspects
        { planet1: 'uranus', planet2: 'neptune', type: 'conjunction', orb: 3 },
        // Pluto aspects
        { planet1: 'pluto', planet2: 'neptune', type: 'sextile', orb: 2 },
    ];

    // Get aspects for a specific planet
    const getAspectsForPlanet = (planetId) => {
        return aspects.filter(a => a.planet1 === planetId || a.planet2 === planetId)
            .map(a => {
                const otherPlanetId = a.planet1 === planetId ? a.planet2 : a.planet1;
                const otherPlanet = planets.find(p => p.id === otherPlanetId);
                return {
                    ...a,
                    otherPlanet,
                    aspectType: aspectTypes[a.type],
                };
            });
    };

    const handleAspectPlay = (aspect) => {
        if (playingAspect?.planet1 === aspect.planet1 && playingAspect?.planet2 === aspect.planet2) {
            setPlayingAspect(null);
            setPlayingPlanet(null);
        } else {
            setPlayingAspect(aspect);
            setPlayingPlanet(null);
        }
    };

    const handlePlanetClick = (planet) => {
        if (playingPlanet?.id === planet.id) {
            setPlayingPlanet(null);
            setSelectedPlanet(null);
        } else {
            setSelectedPlanet(planet);
            setPlayingPlanet(planet);
            setPlayingAspect(null);
        }
    };

    const getPositionOnWheel = (angle, radius) => {
        const radian = (angle - 90) * (Math.PI / 180);
        return {
            x: Math.cos(radian) * radius,
            y: Math.sin(radian) * radius,
        };
    };

    return (
        <div style={{
            minHeight: '100vh',
            background: '#0A0A0F',
            fontFamily: "'Syne', sans-serif",
            color: '#FFFFFF',
            position: 'relative',
            overflow: 'hidden',
        }}>
            <style>{`
        @import url('https://fonts.googleapis.com/css2?family=Syne:wght@400;500;600;700;800&family=Space+Grotesk:wght@300;400;500&display=swap');
        
        @keyframes pulse {
          0%, 100% { transform: scale(1); opacity: 0.8; }
          50% { transform: scale(1.1); opacity: 1; }
        }
        
        @keyframes rotate {
          from { transform: rotate(0deg); }
          to { transform: rotate(360deg); }
        }
        
        @keyframes glow {
          0%, 100% { filter: drop-shadow(0 0 8px currentColor); }
          50% { filter: drop-shadow(0 0 20px currentColor); }
        }
        
        @keyframes soundWave {
          0% { transform: scale(1); opacity: 0.8; }
          100% { transform: scale(2.5); opacity: 0; }
        }
        
        @keyframes waveform {
          0%, 100% { transform: scaleY(0.3); }
          50% { transform: scaleY(1); }
        }
        
        @keyframes linePulse {
          0%, 100% { opacity: 0.6; }
          50% { opacity: 1; }
        }
        
        @keyframes lineGlow {
          0%, 100% { filter: drop-shadow(0 0 2px currentColor); }
          50% { filter: drop-shadow(0 0 8px currentColor); }
        }
        
        .glass-card {
          background: rgba(255, 255, 255, 0.03);
          backdrop-filter: blur(20px);
          -webkit-backdrop-filter: blur(20px);
          border: 1px solid rgba(255, 255, 255, 0.06);
          border-radius: 20px;
        }
        
        .planet-node {
          cursor: pointer;
          transition: all 0.3s ease;
        }
        
        .planet-node:hover {
          transform: scale(1.15);
        }
        
        .planet-node.playing {
          animation: pulse 1.5s ease-in-out infinite;
        }
        
        .wheel-ring {
          animation: rotate 120s linear infinite;
        }
        
        .wheel-ring-reverse {
          animation: rotate 90s linear infinite reverse;
        }
      `}</style>

            {/* Background glow */}
            <div style={{
                position: 'absolute',
                top: '20%',
                left: '50%',
                transform: 'translateX(-50%)',
                width: '400px',
                height: '400px',
                background: playingPlanet
                    ? `radial-gradient(circle, ${playingPlanet.color}30 0%, transparent 60%)`
                    : 'radial-gradient(circle, rgba(125, 103, 254, 0.1) 0%, transparent 60%)',
                borderRadius: '50%',
                filter: 'blur(60px)',
                transition: 'background 0.5s ease',
                pointerEvents: 'none',
            }} />

            {/* Main Container */}
            <div style={{
                maxWidth: '420px',
                margin: '0 auto',
                padding: '20px',
                position: 'relative',
                zIndex: 10,
            }}>

                {/* Header */}
                <div style={{
                    display: 'flex',
                    justifyContent: 'space-between',
                    alignItems: 'center',
                    padding: '16px 0 24px',
                }}>
                    <button style={{
                        background: 'rgba(255, 255, 255, 0.05)',
                        border: '1px solid rgba(255, 255, 255, 0.08)',
                        borderRadius: '12px',
                        padding: '10px',
                        cursor: 'pointer',
                    }}>
                        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="white" strokeWidth="2">
                            <path d="M19 12H5M12 19l-7-7 7-7" />
                        </svg>
                    </button>

                    <h1 style={{ fontSize: '18px', fontWeight: 700, margin: 0 }}>Your Birth Chart</h1>

                    <button style={{
                        background: 'rgba(255, 255, 255, 0.05)',
                        border: '1px solid rgba(255, 255, 255, 0.08)',
                        borderRadius: '12px',
                        padding: '10px',
                        cursor: 'pointer',
                    }}>
                        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="white" strokeWidth="2">
                            <circle cx="12" cy="12" r="1" /><circle cx="12" cy="5" r="1" /><circle cx="12" cy="19" r="1" />
                        </svg>
                    </button>
                </div>

                {/* Birth Chart Wheel */}
                <div style={{
                    position: 'relative',
                    width: '340px',
                    height: '340px',
                    margin: '0 auto 24px',
                }}>
                    {/* Outer ring - Signs */}
                    <svg
                        width="340"
                        height="340"
                        viewBox="0 0 340 340"
                        style={{ position: 'absolute', top: 0, left: 0 }}
                    >
                        {/* Background circles */}
                        <circle cx="170" cy="170" r="165" fill="none" stroke="rgba(255,255,255,0.05)" strokeWidth="1" />
                        <circle cx="170" cy="170" r="140" fill="none" stroke="rgba(255,255,255,0.08)" strokeWidth="1" />
                        <circle cx="170" cy="170" r="100" fill="none" stroke="rgba(255,255,255,0.05)" strokeWidth="1" />
                        <circle cx="170" cy="170" r="60" fill="rgba(255,255,255,0.02)" stroke="rgba(255,255,255,0.08)" strokeWidth="1" />

                        {/* House dividers (12 lines) */}
                        {[...Array(12)].map((_, i) => {
                            const angle = i * 30 - 90;
                            const radian = angle * (Math.PI / 180);
                            const x2 = 170 + Math.cos(radian) * 140;
                            const y2 = 170 + Math.sin(radian) * 140;
                            const x1 = 170 + Math.cos(radian) * 60;
                            const y1 = 170 + Math.sin(radian) * 60;
                            return (
                                <line
                                    key={i}
                                    x1={x1} y1={y1} x2={x2} y2={y2}
                                    stroke="rgba(255,255,255,0.08)"
                                    strokeWidth="1"
                                />
                            );
                        })}

                        {/* Sign icons around outer edge */}
                        {signs.map((sign, i) => {
                            const angle = i * 30 + 15 - 90;
                            const pos = getPositionOnWheel(angle + 90, 152);
                            return (
                                <foreignObject
                                    key={sign.name}
                                    x={170 + pos.x - 10}
                                    y={170 + pos.y - 10}
                                    width="20"
                                    height="20"
                                    style={{
                                        overflow: 'visible',
                                    }}
                                >
                                    <div style={{
                                        width: '20px',
                                        height: '20px',
                                        color: sign.color,
                                        filter: `drop-shadow(0 0 4px ${sign.color}40)`,
                                    }}>
                                        {zodiacIcons[sign.name](sign.color)}
                                    </div>
                                </foreignObject>
                            );
                        })}

                        {/* House numbers */}
                        {[...Array(12)].map((_, i) => {
                            const angle = i * 30 + 15 - 90;
                            const pos = getPositionOnWheel(angle + 90, 75);
                            return (
                                <text
                                    key={i}
                                    x={170 + pos.x}
                                    y={170 + pos.y}
                                    textAnchor="middle"
                                    dominantBaseline="middle"
                                    fill="rgba(255,255,255,0.2)"
                                    fontSize="10"
                                    fontFamily="Space Grotesk, sans-serif"
                                >
                                    {i + 1}
                                </text>
                            );
                        })}

                        {/* Aspect lines - only show when a planet is selected */}
                        {selectedPlanet && getAspectsForPlanet(selectedPlanet.id).map((aspect, index) => {
                            const planet1 = selectedPlanet;
                            const planet2 = aspect.otherPlanet;
                            const pos1 = getPositionOnWheel(planet1.angle, 115);
                            const pos2 = getPositionOnWheel(planet2.angle, 115);
                            const aspectStyle = aspect.aspectType;
                            const isAspectPlaying = playingAspect?.planet1 === aspect.planet1 &&
                                playingAspect?.planet2 === aspect.planet2;

                            return (
                                <g key={index}>
                                    {/* Glow effect line */}
                                    <line
                                        x1={170 + pos1.x}
                                        y1={170 + pos1.y}
                                        x2={170 + pos2.x}
                                        y2={170 + pos2.y}
                                        stroke={aspectStyle.color}
                                        strokeWidth={isAspectPlaying ? "6" : "4"}
                                        strokeLinecap="round"
                                        strokeDasharray={aspectStyle.dash || "none"}
                                        opacity={isAspectPlaying ? "0.4" : "0.2"}
                                        style={{
                                            filter: `blur(${isAspectPlaying ? '4px' : '3px'})`,
                                        }}
                                    />
                                    {/* Main line */}
                                    <line
                                        x1={170 + pos1.x}
                                        y1={170 + pos1.y}
                                        x2={170 + pos2.x}
                                        y2={170 + pos2.y}
                                        stroke={aspectStyle.color}
                                        strokeWidth={isAspectPlaying ? "3" : "2"}
                                        strokeLinecap="round"
                                        strokeDasharray={aspectStyle.dash || "none"}
                                        opacity={isAspectPlaying ? "1" : "0.7"}
                                        style={{
                                            cursor: 'pointer',
                                            animation: isAspectPlaying ? 'linePulse 1s ease-in-out infinite' : 'none',
                                        }}
                                        onClick={(e) => {
                                            e.stopPropagation();
                                            handleAspectPlay(aspect);
                                        }}
                                    />
                                    {/* Clickable invisible wider line for easier tapping */}
                                    <line
                                        x1={170 + pos1.x}
                                        y1={170 + pos1.y}
                                        x2={170 + pos2.x}
                                        y2={170 + pos2.y}
                                        stroke="transparent"
                                        strokeWidth="20"
                                        strokeLinecap="round"
                                        style={{ cursor: 'pointer' }}
                                        onClick={(e) => {
                                            e.stopPropagation();
                                            handleAspectPlay(aspect);
                                        }}
                                    />
                                </g>
                            );
                        })}
                    </svg>

                    {/* Playing planet sound waves */}
                    {playingPlanet && (
                        <>
                            <div style={{
                                position: 'absolute',
                                top: '50%',
                                left: '50%',
                                transform: 'translate(-50%, -50%)',
                                width: '80px',
                                height: '80px',
                                border: `2px solid ${playingPlanet.color}`,
                                borderRadius: '50%',
                                animation: 'soundWave 2s ease-out infinite',
                                pointerEvents: 'none',
                            }} />
                            <div style={{
                                position: 'absolute',
                                top: '50%',
                                left: '50%',
                                transform: 'translate(-50%, -50%)',
                                width: '80px',
                                height: '80px',
                                border: `2px solid ${playingPlanet.color}`,
                                borderRadius: '50%',
                                animation: 'soundWave 2s ease-out infinite 0.5s',
                                pointerEvents: 'none',
                            }} />
                        </>
                    )}

                    {/* Center - Playing indicator or prompt */}
                    <div style={{
                        position: 'absolute',
                        top: '50%',
                        left: '50%',
                        transform: 'translate(-50%, -50%)',
                        width: '100px',
                        height: '100px',
                        borderRadius: '50%',
                        background: playingAspect
                            ? `linear-gradient(135deg, ${aspectTypes[playingAspect.type].color}40 0%, ${aspectTypes[playingAspect.type].color}10 100%)`
                            : playingPlanet
                                ? `linear-gradient(135deg, ${playingPlanet.color}40 0%, ${playingPlanet.color}10 100%)`
                                : 'rgba(255,255,255,0.02)',
                        border: `1px solid ${playingAspect
                                ? aspectTypes[playingAspect.type].color + '50'
                                : playingPlanet
                                    ? playingPlanet.color + '50'
                                    : 'rgba(255,255,255,0.08)'
                            }`,
                        display: 'flex',
                        flexDirection: 'column',
                        alignItems: 'center',
                        justifyContent: 'center',
                        transition: 'all 0.3s ease',
                    }}>
                        {playingAspect ? (
                            <>
                                <div style={{ display: 'flex', gap: '3px', alignItems: 'center', marginBottom: '4px' }}>
                                    {[0.4, 0.8, 1, 0.7, 0.5].map((h, i) => (
                                        <div key={i} style={{
                                            width: '3px',
                                            height: '18px',
                                            background: aspectTypes[playingAspect.type].color,
                                            borderRadius: '2px',
                                            animation: `waveform ${0.25 + i * 0.08}s ease-in-out infinite`,
                                            animationDelay: `${i * 0.04}s`,
                                        }} />
                                    ))}
                                </div>
                                <div style={{
                                    display: 'flex',
                                    alignItems: 'center',
                                    gap: '4px',
                                    fontSize: '10px',
                                    fontWeight: 600,
                                    color: aspectTypes[playingAspect.type].color,
                                    fontFamily: "'Space Grotesk', sans-serif",
                                }}>
                                    <span>{planets.find(p => p.id === playingAspect.planet1)?.frequency}</span>
                                    <span style={{ opacity: 0.5 }}>+</span>
                                    <span>{planets.find(p => p.id === playingAspect.planet2)?.frequency}</span>
                                    <span style={{ opacity: 0.5 }}>Hz</span>
                                </div>
                            </>
                        ) : playingPlanet ? (
                            <>
                                <div style={{ display: 'flex', gap: '3px', alignItems: 'center', marginBottom: '6px' }}>
                                    {[0.3, 0.7, 1, 0.6, 0.4].map((h, i) => (
                                        <div key={i} style={{
                                            width: '3px',
                                            height: '20px',
                                            background: playingPlanet.color,
                                            borderRadius: '2px',
                                            animation: `waveform ${0.3 + i * 0.1}s ease-in-out infinite`,
                                            animationDelay: `${i * 0.05}s`,
                                        }} />
                                    ))}
                                </div>
                                <span style={{
                                    fontSize: '12px',
                                    fontWeight: 700,
                                    color: playingPlanet.color,
                                    fontFamily: "'Space Grotesk', sans-serif",
                                }}>{playingPlanet.frequency} Hz</span>
                            </>
                        ) : (
                            <span style={{
                                fontSize: '11px',
                                color: 'rgba(255,255,255,0.4)',
                                textAlign: 'center',
                                padding: '0 10px',
                            }}>Tap a planet to listen</span>
                        )}
                    </div>

                    {/* Planet nodes */}
                    {planets.map((planet) => {
                        const pos = getPositionOnWheel(planet.angle, 115);
                        const isPlaying = playingPlanet?.id === planet.id;
                        const isSelected = selectedPlanet?.id === planet.id;

                        return (
                            <div
                                key={planet.id}
                                className={`planet-node ${isPlaying ? 'playing' : ''}`}
                                onClick={() => handlePlanetClick(planet)}
                                style={{
                                    position: 'absolute',
                                    left: `calc(50% + ${pos.x}px - 22px)`,
                                    top: `calc(50% + ${pos.y}px - 22px)`,
                                    width: '44px',
                                    height: '44px',
                                    borderRadius: '50%',
                                    background: isPlaying
                                        ? `linear-gradient(135deg, ${planet.color} 0%, ${planet.color}80 100%)`
                                        : `linear-gradient(135deg, ${planet.color}30 0%, ${planet.color}10 100%)`,
                                    border: `2px solid ${isPlaying ? planet.color : planet.color + '60'}`,
                                    display: 'flex',
                                    alignItems: 'center',
                                    justifyContent: 'center',
                                    boxShadow: isPlaying ? `0 0 20px ${planet.color}60` : 'none',
                                    zIndex: isSelected ? 10 : 1,
                                }}
                            >
                                <span style={{
                                    fontSize: '20px',
                                    color: isPlaying ? '#0A0A0F' : planet.color,
                                    textShadow: isPlaying ? 'none' : `0 0 10px ${planet.color}`,
                                }}>{planet.symbol}</span>
                            </div>
                        );
                    })}
                </div>

                {/* Selected Planet Info Card */}
                {selectedPlanet && (
                    <div className="glass-card" style={{
                        padding: '20px',
                        marginBottom: '20px',
                        borderTop: `3px solid ${selectedPlanet.color}`,
                    }}>
                        <div style={{
                            display: 'flex',
                            alignItems: 'center',
                            justifyContent: 'space-between',
                            marginBottom: '16px',
                        }}>
                            <div style={{ display: 'flex', alignItems: 'center', gap: '14px' }}>
                                <div style={{
                                    width: '52px',
                                    height: '52px',
                                    borderRadius: '50%',
                                    background: `linear-gradient(135deg, ${selectedPlanet.color}40 0%, ${selectedPlanet.color}15 100%)`,
                                    border: `2px solid ${selectedPlanet.color}`,
                                    display: 'flex',
                                    alignItems: 'center',
                                    justifyContent: 'center',
                                }}>
                                    <span style={{ fontSize: '26px', color: selectedPlanet.color }}>{selectedPlanet.symbol}</span>
                                </div>
                                <div>
                                    <h3 style={{ fontSize: '20px', fontWeight: 700, margin: '0 0 4px 0' }}>{selectedPlanet.name}</h3>
                                    <p style={{
                                        fontSize: '13px',
                                        color: 'rgba(255,255,255,0.6)',
                                        margin: 0,
                                        fontFamily: "'Space Grotesk', sans-serif",
                                    }}>
                                        in {selectedPlanet.sign} • House {selectedPlanet.house}
                                    </p>
                                </div>
                            </div>

                            {/* Play/Pause Button */}
                            <button
                                onClick={() => handlePlanetClick(selectedPlanet)}
                                style={{
                                    width: '48px',
                                    height: '48px',
                                    borderRadius: '50%',
                                    background: playingPlanet?.id === selectedPlanet.id
                                        ? selectedPlanet.color
                                        : 'rgba(255,255,255,0.1)',
                                    border: 'none',
                                    cursor: 'pointer',
                                    display: 'flex',
                                    alignItems: 'center',
                                    justifyContent: 'center',
                                }}
                            >
                                {playingPlanet?.id === selectedPlanet.id ? (
                                    <svg width="20" height="20" viewBox="0 0 24 24" fill="#0A0A0F">
                                        <rect x="6" y="4" width="4" height="16" rx="1" />
                                        <rect x="14" y="4" width="4" height="16" rx="1" />
                                    </svg>
                                ) : (
                                    <svg width="20" height="20" viewBox="0 0 24 24" fill="white">
                                        <polygon points="6,4 20,12 6,20" />
                                    </svg>
                                )}
                            </button>
                        </div>

                        {/* Stats Row */}
                        <div style={{
                            display: 'flex',
                            gap: '12px',
                            marginBottom: '16px',
                        }}>
                            <div style={{
                                flex: 1,
                                background: 'rgba(255,255,255,0.04)',
                                borderRadius: '12px',
                                padding: '12px',
                                textAlign: 'center',
                            }}>
                                <p style={{
                                    fontSize: '10px',
                                    color: 'rgba(255,255,255,0.5)',
                                    margin: '0 0 4px 0',
                                    textTransform: 'uppercase',
                                    letterSpacing: '1px',
                                }}>Frequency</p>
                                <p style={{
                                    fontSize: '18px',
                                    fontWeight: 700,
                                    color: selectedPlanet.color,
                                    margin: 0,
                                    fontFamily: "'Space Grotesk', sans-serif",
                                }}>{selectedPlanet.frequency} Hz</p>
                            </div>

                            <div style={{
                                flex: 1,
                                background: 'rgba(255,255,255,0.04)',
                                borderRadius: '12px',
                                padding: '12px',
                                textAlign: 'center',
                            }}>
                                <p style={{
                                    fontSize: '10px',
                                    color: 'rgba(255,255,255,0.5)',
                                    margin: '0 0 4px 0',
                                    textTransform: 'uppercase',
                                    letterSpacing: '1px',
                                }}>Intensity</p>
                                <p style={{
                                    fontSize: '18px',
                                    fontWeight: 700,
                                    color: 'white',
                                    margin: 0,
                                    fontFamily: "'Space Grotesk', sans-serif",
                                }}>{selectedPlanet.intensity}%</p>
                            </div>

                            <div style={{
                                flex: 1,
                                background: 'rgba(255,255,255,0.04)',
                                borderRadius: '12px',
                                padding: '12px',
                                textAlign: 'center',
                            }}>
                                <p style={{
                                    fontSize: '10px',
                                    color: 'rgba(255,255,255,0.5)',
                                    margin: '0 0 4px 0',
                                    textTransform: 'uppercase',
                                    letterSpacing: '1px',
                                }}>House</p>
                                <p style={{
                                    fontSize: '18px',
                                    fontWeight: 700,
                                    color: 'white',
                                    margin: 0,
                                    fontFamily: "'Space Grotesk', sans-serif",
                                }}>{selectedPlanet.house}</p>
                            </div>
                        </div>

                        {/* Aspects List */}
                        {getAspectsForPlanet(selectedPlanet.id).length > 0 && (
                            <div>
                                <p style={{
                                    fontSize: '10px',
                                    color: 'rgba(255,255,255,0.5)',
                                    textTransform: 'uppercase',
                                    letterSpacing: '1.5px',
                                    margin: '0 0 10px 0',
                                }}>Aspects</p>
                                <div style={{ display: 'flex', flexDirection: 'column', gap: '8px' }}>
                                    {getAspectsForPlanet(selectedPlanet.id).map((aspect, index) => {
                                        const isPlaying = playingAspect?.planet1 === aspect.planet1 &&
                                            playingAspect?.planet2 === aspect.planet2;
                                        return (
                                            <div
                                                key={index}
                                                onClick={() => handleAspectPlay(aspect)}
                                                style={{
                                                    display: 'flex',
                                                    alignItems: 'center',
                                                    gap: '12px',
                                                    padding: '10px 12px',
                                                    background: isPlaying
                                                        ? `${aspect.aspectType.color}20`
                                                        : 'rgba(255,255,255,0.03)',
                                                    borderRadius: '10px',
                                                    borderLeft: `3px solid ${aspect.aspectType.color}`,
                                                    cursor: 'pointer',
                                                    transition: 'all 0.2s ease',
                                                }}
                                            >
                                                {/* Aspect line indicator */}
                                                <div style={{
                                                    width: '24px',
                                                    display: 'flex',
                                                    alignItems: 'center',
                                                    justifyContent: 'center',
                                                }}>
                                                    <div style={{
                                                        width: '20px',
                                                        height: '2px',
                                                        background: aspect.aspectType.color,
                                                        borderRadius: '1px',
                                                        ...(aspect.aspectType.dash && {
                                                            backgroundImage: `repeating-linear-gradient(90deg, ${aspect.aspectType.color} 0px, ${aspect.aspectType.color} 4px, transparent 4px, transparent 8px)`,
                                                            background: 'none',
                                                        }),
                                                    }}>
                                                        {aspect.aspectType.dash && (
                                                            <svg width="20" height="2">
                                                                <line
                                                                    x1="0" y1="1" x2="20" y2="1"
                                                                    stroke={aspect.aspectType.color}
                                                                    strokeWidth="2"
                                                                    strokeDasharray={aspect.aspectType.dash}
                                                                />
                                                            </svg>
                                                        )}
                                                    </div>
                                                </div>

                                                {/* Aspect info */}
                                                <div style={{ flex: 1 }}>
                                                    <p style={{
                                                        fontSize: '13px',
                                                        fontWeight: 600,
                                                        margin: 0,
                                                        color: 'white',
                                                    }}>
                                                        {aspect.aspectType.name} {aspect.otherPlanet.name}
                                                    </p>
                                                    <p style={{
                                                        fontSize: '11px',
                                                        color: 'rgba(255,255,255,0.5)',
                                                        margin: '2px 0 0 0',
                                                        fontFamily: "'Space Grotesk', sans-serif",
                                                    }}>
                                                        {aspect.otherPlanet.frequency} Hz • {aspect.aspectType.harmony}
                                                    </p>
                                                </div>

                                                {/* Play button */}
                                                <button
                                                    onClick={(e) => {
                                                        e.stopPropagation();
                                                        handleAspectPlay(aspect);
                                                    }}
                                                    style={{
                                                        width: '32px',
                                                        height: '32px',
                                                        borderRadius: '50%',
                                                        background: isPlaying
                                                            ? aspect.aspectType.color
                                                            : 'rgba(255,255,255,0.1)',
                                                        border: 'none',
                                                        cursor: 'pointer',
                                                        display: 'flex',
                                                        alignItems: 'center',
                                                        justifyContent: 'center',
                                                    }}
                                                >
                                                    {isPlaying ? (
                                                        <svg width="12" height="12" viewBox="0 0 24 24" fill="#0A0A0F">
                                                            <rect x="6" y="4" width="4" height="16" rx="1" />
                                                            <rect x="14" y="4" width="4" height="16" rx="1" />
                                                        </svg>
                                                    ) : (
                                                        <svg width="12" height="12" viewBox="0 0 24 24" fill="white">
                                                            <polygon points="6,4 20,12 6,20" />
                                                        </svg>
                                                    )}
                                                </button>
                                            </div>
                                        );
                                    })}
                                </div>
                            </div>
                        )}
                    </div>
                )}

                {/* Planet List - Quick Select */}
                <div style={{ marginBottom: '100px' }}>
                    <h3 style={{
                        fontSize: '12px',
                        fontWeight: 600,
                        margin: '0 0 12px 0',
                        color: 'rgba(255,255,255,0.5)',
                        textTransform: 'uppercase',
                        letterSpacing: '1.5px',
                    }}>All Planets</h3>

                    <div style={{
                        display: 'flex',
                        flexWrap: 'wrap',
                        gap: '8px',
                    }}>
                        {planets.map((planet) => {
                            const isPlaying = playingPlanet?.id === planet.id;
                            return (
                                <button
                                    key={planet.id}
                                    onClick={() => handlePlanetClick(planet)}
                                    style={{
                                        background: isPlaying
                                            ? `linear-gradient(135deg, ${planet.color} 0%, ${planet.color}80 100%)`
                                            : 'rgba(255,255,255,0.04)',
                                        border: `1px solid ${isPlaying ? planet.color : 'rgba(255,255,255,0.08)'}`,
                                        borderRadius: '20px',
                                        padding: '8px 14px',
                                        cursor: 'pointer',
                                        display: 'flex',
                                        alignItems: 'center',
                                        gap: '6px',
                                        transition: 'all 0.2s ease',
                                    }}
                                >
                                    <span style={{
                                        fontSize: '14px',
                                        color: isPlaying ? '#0A0A0F' : planet.color
                                    }}>{planet.symbol}</span>
                                    <span style={{
                                        fontSize: '12px',
                                        fontWeight: 600,
                                        color: isPlaying ? '#0A0A0F' : 'rgba(255,255,255,0.8)',
                                    }}>{planet.name}</span>
                                </button>
                            );
                        })}
                    </div>
                </div>

                {/* Play All Button */}
                <div style={{
                    position: 'fixed',
                    bottom: '100px',
                    left: '50%',
                    transform: 'translateX(-50%)',
                    width: 'calc(100% - 40px)',
                    maxWidth: '380px',
                }}>
                    <button style={{
                        width: '100%',
                        background: 'linear-gradient(135deg, #7D67FE 0%, #FF59D0 100%)',
                        border: 'none',
                        borderRadius: '16px',
                        padding: '16px',
                        fontSize: '14px',
                        fontWeight: 700,
                        fontFamily: "'Syne', sans-serif",
                        color: '#FFFFFF',
                        cursor: 'pointer',
                        display: 'flex',
                        alignItems: 'center',
                        justifyContent: 'center',
                        gap: '10px',
                        boxShadow: '0 8px 24px rgba(125, 103, 254, 0.3)',
                    }}>
                        <svg width="18" height="18" viewBox="0 0 24 24" fill="currentColor">
                            <polygon points="6,4 20,12 6,20" />
                        </svg>
                        Play Full Sound Signature
                    </button>
                </div>

                {/* Bottom Navigation */}
                <div style={{
                    position: 'fixed',
                    bottom: 0,
                    left: '50%',
                    transform: 'translateX(-50%)',
                    width: '100%',
                    maxWidth: '420px',
                    padding: '0 20px 24px',
                    boxSizing: 'border-box',
                    background: 'linear-gradient(to top, #0A0A0F 0%, #0A0A0F 70%, transparent 100%)',
                    paddingTop: '20px',
                }}>
                    <div className="glass-card" style={{
                        display: 'flex',
                        justifyContent: 'space-around',
                        alignItems: 'center',
                        padding: '12px 8px',
                        borderRadius: '24px',
                    }}>
                        {[
                            { id: 'home', label: 'HOME' },
                            { id: 'sound', label: 'SOUND', active: true },
                            { id: 'align', label: 'ALIGN' },
                            { id: 'friends', label: 'FRIENDS' },
                            { id: 'profile', label: 'PROFILE' },
                        ].map((item) => (
                            <div
                                key={item.id}
                                style={{
                                    display: 'flex',
                                    flexDirection: 'column',
                                    alignItems: 'center',
                                    gap: '4px',
                                    cursor: 'pointer',
                                    padding: '8px 12px',
                                }}
                            >
                                <div style={{
                                    width: '6px',
                                    height: '6px',
                                    borderRadius: '50%',
                                    background: item.active ? '#FAFF0E' : 'transparent',
                                    marginBottom: '2px',
                                }} />
                                <span style={{
                                    fontSize: '9px',
                                    fontWeight: item.active ? 700 : 500,
                                    color: item.active ? '#FAFF0E' : 'rgba(255, 255, 255, 0.4)',
                                    letterSpacing: '0.5px',
                                }}>{item.label}</span>
                            </div>
                        ))}
                    </div>
                </div>
            </div>
        </div>
    );
};

export default BirthChartWheel;