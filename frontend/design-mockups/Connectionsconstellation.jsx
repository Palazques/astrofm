import React, { useState, useMemo } from 'react';

const ConnectionsConstellationV4 = () => {
    const [activeTab, setActiveTab] = useState('connections');
    const [filter, setFilter] = useState('all');
    const [selectedConnection, setSelectedConnection] = useState(null);
    const [hoveredConnection, setHoveredConnection] = useState(null);

    // Friends data - positions will be calculated
    const friends = [
        {
            id: 1,
            name: "Maya Chen",
            initials: "MC",
            sign: "Pisces",
            color: "#FF59D0",
            compatibility: 91,
            lastAligned: "2 hours ago",
            status: "online",
            sharedPlanets: ["Moon", "Venus"],
        },
        {
            id: 2,
            name: "Jordan Rivera",
            initials: "JR",
            sign: "Aries",
            color: "#FAFF0E",
            compatibility: 78,
            lastAligned: "Yesterday",
            status: "online",
            sharedPlanets: ["Mars", "Sun"],
        },
        {
            id: 3,
            name: "Alex Kim",
            initials: "AK",
            sign: "Scorpio",
            color: "#7D67FE",
            compatibility: 87,
            lastAligned: "3 days ago",
            status: "offline",
            sharedPlanets: ["Pluto", "Moon", "Mercury"],
        },
        {
            id: 4,
            name: "Sam Taylor",
            initials: "ST",
            sign: "Leo",
            color: "#00D4AA",
            compatibility: 65,
            lastAligned: "1 week ago",
            status: "offline",
            sharedPlanets: ["Sun"],
        },
        {
            id: 5,
            name: "Riley Morgan",
            initials: "RM",
            sign: "Libra",
            color: "#FF8C42",
            compatibility: 82,
            lastAligned: "4 days ago",
            status: "online",
            sharedPlanets: ["Venus", "Mercury"],
        },
        {
            id: 6,
            name: "Casey Jones",
            initials: "CJ",
            sign: "Virgo",
            color: "#E84855",
            compatibility: 73,
            lastAligned: "5 days ago",
            status: "offline",
            sharedPlanets: ["Mercury"],
        },
        {
            id: 7,
            name: "Drew Park",
            initials: "DP",
            sign: "Aquarius",
            color: "#00B4D8",
            compatibility: 88,
            lastAligned: "1 day ago",
            status: "online",
            sharedPlanets: ["Uranus", "Moon"],
        },
    ];

    const containerWidth = 340;
    const containerHeight = 320;
    const padding = 35; // Keep stars away from edges

    // Seeded random - consistent for same ID
    const seededRandom = (seed) => {
        const x = Math.sin(seed * 9999) * 10000;
        return x - Math.floor(x);
    };

    // Calculate scattered positions across full canvas with collision detection
    const calculatePositions = useMemo(() => {
        const minDistance = 55; // Minimum distance between orb centers
        const maxAttempts = 50; // Prevent infinite loops
        const placedFriends = [];

        return friends.map((friend) => {
            // Use seeded random for initial positioning
            const seed1 = friend.id * 137;
            const seed2 = friend.id * 251;

            let x = padding + seededRandom(seed1) * (containerWidth - padding * 2);
            let y = padding + seededRandom(seed2) * (containerHeight - padding * 2);

            // Check for overlaps and nudge if needed
            let attempts = 0;
            let hasOverlap = true;

            while (hasOverlap && attempts < maxAttempts) {
                hasOverlap = false;

                for (const placed of placedFriends) {
                    const distance = Math.sqrt(
                        Math.pow(x - placed.x, 2) + Math.pow(y - placed.y, 2)
                    );

                    if (distance < minDistance) {
                        hasOverlap = true;

                        // Nudge away from the overlapping orb
                        const angle = Math.atan2(y - placed.y, x - placed.x);
                        const nudgeDistance = minDistance - distance + 5;

                        x += Math.cos(angle) * nudgeDistance;
                        y += Math.sin(angle) * nudgeDistance;

                        // Keep within bounds
                        x = Math.max(padding, Math.min(containerWidth - padding, x));
                        y = Math.max(padding, Math.min(containerHeight - padding, y));

                        break;
                    }
                }

                attempts++;
            }

            const positioned = { ...friend, x, y };
            placedFriends.push(positioned);

            return positioned;
        });
    }, [friends]);

    // Sign compatibility matrix (same element = high, compatible elements = medium)
    const signElements = {
        'Aries': 'fire', 'Leo': 'fire', 'Sagittarius': 'fire',
        'Taurus': 'earth', 'Virgo': 'earth', 'Capricorn': 'earth',
        'Gemini': 'air', 'Libra': 'air', 'Aquarius': 'air',
        'Cancer': 'water', 'Scorpio': 'water', 'Pisces': 'water',
    };

    const elementCompatibility = {
        'fire': { 'fire': 90, 'air': 80, 'earth': 50, 'water': 40 },
        'earth': { 'earth': 90, 'water': 80, 'fire': 50, 'air': 40 },
        'air': { 'air': 90, 'fire': 80, 'water': 50, 'earth': 40 },
        'water': { 'water': 90, 'earth': 80, 'air': 50, 'fire': 40 },
    };

    // Calculate compatibility between two friends based on their signs
    const getFriendCompatibility = (friend1, friend2) => {
        const element1 = signElements[friend1.sign];
        const element2 = signElements[friend2.sign];

        if (!element1 || !element2) return 50;

        const baseCompat = elementCompatibility[element1][element2];

        // Add some variance based on their IDs for uniqueness
        const variance = (seededRandom(friend1.id * friend2.id) - 0.5) * 20;

        return Math.round(baseCompat + variance);
    };

    // Compatibility threshold for connection
    const compatibilityThreshold = 70;

    // Calculate compatibility-based connections between friends
    const friendConnections = useMemo(() => {
        const connections = [];

        for (let i = 0; i < calculatePositions.length; i++) {
            for (let j = i + 1; j < calculatePositions.length; j++) {
                const f1 = calculatePositions[i];
                const f2 = calculatePositions[j];

                const compatibility = getFriendCompatibility(f1, f2);

                if (compatibility >= compatibilityThreshold) {
                    connections.push({
                        from: f1,
                        to: f2,
                        compatibility,
                    });
                }
            }
        }

        return connections;
    }, [calculatePositions]);

    // Find connected friends for a given friend
    const getConnectedFriends = (friendId) => {
        const connected = [];
        friendConnections.forEach(conn => {
            if (conn.from.id === friendId) connected.push(conn.to);
            if (conn.to.id === friendId) connected.push(conn.from);
        });
        return connected;
    };

    const pendingRequests = [
        { id: 101, name: "Chris Lee", initials: "CL", sign: "Capricorn", color1: "#7D67FE", color2: "#FAFF0E" },
    ];

    const getCompatibilityColor = (score) => {
        if (score >= 85) return '#00D4AA';
        if (score >= 70) return '#FAFF0E';
        if (score >= 50) return '#FF8C42';
        return '#E84855';
    };

    const getPlanetSymbol = (planet) => {
        const symbols = {
            'Sun': '☉', 'Moon': '☽', 'Mercury': '☿', 'Venus': '♀',
            'Mars': '♂', 'Jupiter': '♃', 'Saturn': '♄', 'Uranus': '♅',
            'Neptune': '♆', 'Pluto': '♇',
        };
        return symbols[planet] || '★';
    };

    const isStarHighlighted = (friendId) => {
        if (!selectedConnection && !hoveredConnection) return false;
        const activeId = selectedConnection?.id || hoveredConnection?.id;

        if (friendId === activeId) return true;

        // Check if connected via proximity
        const connected = getConnectedFriends(activeId);
        return connected.some(f => f.id === friendId);
    };

    const isLineHighlighted = (fromId, toId) => {
        if (!selectedConnection && !hoveredConnection) return false;
        const activeId = selectedConnection?.id || hoveredConnection?.id;
        return fromId === activeId || toId === activeId;
    };

    return (
        <div style={{
            minHeight: '100vh',
            background: 'linear-gradient(180deg, #06060A 0%, #0A0A10 50%, #080810 100%)',
            fontFamily: "'Syne', sans-serif",
            color: '#FFFFFF',
            position: 'relative',
            overflow: 'hidden',
        }}>
            <style>{`
        @import url('https://fonts.googleapis.com/css2?family=Syne:wght@400;500;600;700;800&family=Space+Grotesk:wght@300;400;500&display=swap');
        
        @keyframes twinkle {
          0%, 100% { opacity: 0.3; }
          50% { opacity: 0.8; }
        }
        
        @keyframes float {
          0%, 100% { transform: translateY(0); }
          50% { transform: translateY(-3px); }
        }
        
        @keyframes glow {
          0%, 100% { opacity: 0.4; }
          50% { opacity: 0.7; }
        }
        
        .glass-card {
          background: rgba(255, 255, 255, 0.02);
          backdrop-filter: blur(20px);
          -webkit-backdrop-filter: blur(20px);
          border: 1px solid rgba(255, 255, 255, 0.05);
          border-radius: 24px;
        }
        
        .filter-button {
          padding: 10px 18px;
          background: transparent;
          border: 1px solid rgba(255, 255, 255, 0.1);
          color: rgba(255, 255, 255, 0.5);
          font-family: 'Syne', sans-serif;
          font-size: 12px;
          font-weight: 600;
          cursor: pointer;
          transition: all 0.3s ease;
          border-radius: 20px;
        }
        
        .filter-button.active {
          background: rgba(250, 255, 14, 0.15);
          border-color: rgba(250, 255, 14, 0.3);
          color: #FAFF0E;
        }
        
        .star {
          position: absolute;
          cursor: pointer;
          transition: all 0.3s ease;
        }
        
        .star:hover {
          transform: scale(1.2);
          z-index: 10;
        }
        
        .star.selected {
          transform: scale(1.25);
          z-index: 10;
        }
        
        .star.dimmed {
          opacity: 0.3;
        }
        
        .bg-star {
          position: absolute;
          background: white;
          border-radius: 50%;
          animation: twinkle 3s ease-in-out infinite;
        }
        
        .constellation-line {
          transition: all 0.3s ease;
        }
        
        .name-label {
          position: absolute;
          font-size: 9px;
          font-weight: 600;
          letter-spacing: 0.5px;
          white-space: nowrap;
          opacity: 0;
          transition: opacity 0.2s ease;
          pointer-events: none;
          text-shadow: 0 2px 10px rgba(0,0,0,1);
          left: 50%;
          transform: translateX(-50%);
          top: calc(100% + 6px);
        }
        
        .star:hover .name-label,
        .star.selected .name-label {
          opacity: 1;
        }
        
        .nav-item {
          transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
        }
        
        .nav-item:hover {
          transform: translateY(-2px);
        }
      `}</style>

            {/* Background Stars - dense star field */}
            {[...Array(80)].map((_, i) => (
                <div
                    key={i}
                    className="bg-star"
                    style={{
                        left: `${Math.random() * 100}%`,
                        top: `${Math.random() * 60}%`,
                        width: `${Math.random() < 0.9 ? 1 : 2}px`,
                        height: `${Math.random() < 0.9 ? 1 : 2}px`,
                        animationDelay: `${Math.random() * 5}s`,
                        animationDuration: `${2 + Math.random() * 4}s`,
                        opacity: Math.random() * 0.4 + 0.1,
                    }}
                />
            ))}

            {/* Subtle nebula */}
            <div style={{
                position: 'absolute',
                top: '20%',
                left: '5%',
                width: '200px',
                height: '200px',
                background: 'radial-gradient(circle, rgba(125, 103, 254, 0.04) 0%, transparent 70%)',
                borderRadius: '50%',
                filter: 'blur(40px)',
            }} />
            <div style={{
                position: 'absolute',
                top: '40%',
                right: '0%',
                width: '180px',
                height: '180px',
                background: 'radial-gradient(circle, rgba(255, 89, 208, 0.03) 0%, transparent 70%)',
                borderRadius: '50%',
                filter: 'blur(35px)',
            }} />

            {/* Main Container */}
            <div style={{
                maxWidth: '420px',
                margin: '0 auto',
                padding: '20px',
                position: 'relative',
                zIndex: 10,
            }}>

                {/* Status Bar */}
                <div style={{
                    display: 'flex',
                    justifyContent: 'space-between',
                    alignItems: 'center',
                    padding: '12px 8px',
                    fontSize: '14px',
                    fontFamily: "'Space Grotesk', sans-serif",
                    fontWeight: 500,
                }}>
                    <span>9:41</span>
                    <div style={{ display: 'flex', gap: '6px', alignItems: 'center' }}>
                        <svg width="18" height="12" viewBox="0 0 18 12" fill="white"><path d="M1 4C1 3.45 1.45 3 2 3H3C3.55 3 4 3.45 4 4V11C4 11.55 3.55 12 3 12H2C1.45 12 1 11.55 1 11V4Z" fillOpacity="0.4" /><path d="M5 3C5 2.45 5.45 2 6 2H7C7.55 2 8 2.45 8 3V11C8 11.55 7.55 12 7 12H6C5.45 12 5 11.55 5 11V3Z" fillOpacity="0.6" /><path d="M9 1C9 0.45 9.45 0 10 0H11C11.55 0 12 0.45 12 1V11C12 11.55 11.55 12 11 12H10C9.45 12 9 11.55 9 11V1Z" /><path d="M13 2C13 1.45 13.45 1 14 1H15C15.55 1 16 1.45 16 2V11C16 11.55 15.55 12 15 12H14C13.45 12 13 11.55 13 11V2Z" /></svg>
                        <div style={{ width: '28px', height: '13px', border: '1.5px solid white', borderRadius: '4px', padding: '2px' }}>
                            <div style={{ width: '80%', height: '100%', background: '#FAFF0E', borderRadius: '2px' }} />
                        </div>
                    </div>
                </div>

                {/* Header */}
                <div style={{
                    display: 'flex',
                    justifyContent: 'space-between',
                    alignItems: 'center',
                    padding: '16px 0 20px',
                }}>
                    <button style={{
                        background: 'rgba(255, 255, 255, 0.05)',
                        border: 'none',
                        borderRadius: '12px',
                        padding: '10px',
                        cursor: 'pointer',
                    }}>
                        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="white" strokeWidth="2">
                            <path d="M3 12h18M3 6h18M3 18h18" />
                        </svg>
                    </button>

                    <h1 style={{ fontSize: '20px', fontWeight: 700, margin: 0 }}>Connections</h1>

                    <button style={{
                        background: 'linear-gradient(135deg, #7D67FE 0%, #FF59D0 100%)',
                        border: 'none',
                        borderRadius: '12px',
                        padding: '10px',
                        cursor: 'pointer',
                    }}>
                        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="white" strokeWidth="2">
                            <path d="M16 21v-2a4 4 0 00-4-4H5a4 4 0 00-4 4v2M12 11a4 4 0 100-8 4 4 0 000 8zM23 21v-2a4 4 0 00-3-3.87M16 3.13a4 4 0 010 7.75" />
                        </svg>
                    </button>
                </div>

                {/* Search Bar */}
                <div style={{
                    background: 'rgba(255, 255, 255, 0.03)',
                    border: '1px solid rgba(255, 255, 255, 0.06)',
                    borderRadius: '16px',
                    padding: '14px 18px',
                    display: 'flex',
                    alignItems: 'center',
                    gap: '12px',
                    marginBottom: '16px',
                }}>
                    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="rgba(255,255,255,0.4)" strokeWidth="2">
                        <circle cx="11" cy="11" r="8" />
                        <path d="M21 21l-4.35-4.35" />
                    </svg>
                    <input
                        type="text"
                        placeholder="Search connections..."
                        style={{
                            flex: 1,
                            background: 'transparent',
                            border: 'none',
                            outline: 'none',
                            color: 'white',
                            fontSize: '14px',
                            fontFamily: "'Space Grotesk', sans-serif",
                        }}
                    />
                </div>

                {/* Filter Buttons */}
                <div style={{
                    display: 'flex',
                    gap: '10px',
                    marginBottom: '20px',
                }}>
                    <button
                        className={`filter-button ${filter === 'all' ? 'active' : ''}`}
                        onClick={() => setFilter('all')}
                    >All</button>
                    <button
                        className={`filter-button ${filter === 'recent' ? 'active' : ''}`}
                        onClick={() => setFilter('recent')}
                    >Recent</button>
                    <button
                        className={`filter-button ${filter === 'compatible' ? 'active' : ''}`}
                        onClick={() => setFilter('compatible')}
                    >Most Compatible</button>
                </div>

                {/* Pending Requests - compact */}
                {pendingRequests.length > 0 && (
                    <div className="glass-card" style={{
                        padding: '14px',
                        display: 'flex',
                        alignItems: 'center',
                        gap: '12px',
                        marginBottom: '20px',
                    }}>
                        <div style={{
                            width: '40px',
                            height: '40px',
                            borderRadius: '50%',
                            background: `linear-gradient(135deg, ${pendingRequests[0].color1} 0%, ${pendingRequests[0].color2} 100%)`,
                            display: 'flex',
                            alignItems: 'center',
                            justifyContent: 'center',
                            fontSize: '14px',
                            fontWeight: 700,
                        }}>{pendingRequests[0].initials}</div>
                        <div style={{ flex: 1 }}>
                            <p style={{ fontSize: '13px', fontWeight: 600, margin: 0 }}>{pendingRequests[0].name}</p>
                            <p style={{ fontSize: '11px', color: 'rgba(255,255,255,0.5)', margin: 0 }}>wants to connect</p>
                        </div>
                        <div style={{ display: 'flex', gap: '8px' }}>
                            <button style={{
                                background: 'rgba(255, 255, 255, 0.1)',
                                border: 'none',
                                borderRadius: '10px',
                                padding: '8px 12px',
                                cursor: 'pointer',
                                color: 'rgba(255,255,255,0.6)',
                                fontSize: '11px',
                                fontWeight: 600,
                            }}>Skip</button>
                            <button style={{
                                background: 'linear-gradient(135deg, #00D4AA 0%, #00B894 100%)',
                                border: 'none',
                                borderRadius: '10px',
                                padding: '8px 12px',
                                cursor: 'pointer',
                                color: 'white',
                                fontSize: '11px',
                                fontWeight: 600,
                            }}>Accept</button>
                        </div>
                    </div>
                )}

                {/* Constellation Map */}
                <div style={{ marginBottom: '16px' }}>
                    <div style={{
                        display: 'flex',
                        alignItems: 'center',
                        gap: '8px',
                        marginBottom: '12px',
                    }}>
                        <span style={{ color: '#FAFF0E', fontSize: '12px' }}>✦</span>
                        <h3 style={{ fontSize: '13px', fontWeight: 600, margin: 0, color: 'rgba(255,255,255,0.6)' }}>
                            Your Constellation
                        </h3>
                        <span style={{ fontSize: '11px', color: 'rgba(255,255,255,0.3)' }}>
                            · {friends.length} stars
                        </span>
                    </div>

                    <div className="glass-card" style={{
                        padding: '12px',
                        position: 'relative',
                    }}>
                        {/* Constellation Container */}
                        <div style={{
                            width: `${containerWidth}px`,
                            height: `${containerHeight}px`,
                            margin: '0 auto',
                            position: 'relative',
                        }}>
                            {/* SVG for constellation lines */}
                            <svg
                                width={containerWidth}
                                height={containerHeight}
                                style={{ position: 'absolute', top: 0, left: 0 }}
                            >
                                {/* Friend to Friend proximity lines only */}
                                {friendConnections.map((conn, i) => {
                                    const isHighlighted = isLineHighlighted(conn.from.id, conn.to.id);
                                    const hasSelection = selectedConnection || hoveredConnection;

                                    return (
                                        <line
                                            key={i}
                                            x1={conn.from.x}
                                            y1={conn.from.y}
                                            x2={conn.to.x}
                                            y2={conn.to.y}
                                            stroke={isHighlighted ? 'rgba(255,255,255,0.5)' : 'rgba(255,255,255,0.15)'}
                                            strokeWidth={isHighlighted ? 1.5 : 1}
                                            className="constellation-line"
                                            style={{
                                                opacity: hasSelection && !isHighlighted ? 0.05 : undefined,
                                            }}
                                        />
                                    );
                                })}
                            </svg>

                            {/* Friend Stars */}
                            {calculatePositions.map((friend) => {
                                const isSelected = selectedConnection?.id === friend.id;
                                const isHighlighted = isStarHighlighted(friend.id);
                                const hasSelection = selectedConnection || hoveredConnection;
                                const isDimmed = hasSelection && !isHighlighted && !isSelected;

                                // Size based on compatibility (brighter = more compatible)
                                const baseSize = 28;
                                const sizeBonus = ((friend.compatibility - 50) / 50) * 12;
                                const size = baseSize + sizeBonus;

                                // Brightness based on compatibility
                                const glowOpacity = 0.2 + ((friend.compatibility - 50) / 50) * 0.4;

                                return (
                                    <div
                                        key={friend.id}
                                        className={`star ${isSelected ? 'selected' : ''} ${isDimmed ? 'dimmed' : ''}`}
                                        onClick={() => setSelectedConnection(isSelected ? null : friend)}
                                        onMouseEnter={() => setHoveredConnection(friend)}
                                        onMouseLeave={() => setHoveredConnection(null)}
                                        style={{
                                            left: friend.x - size / 2,
                                            top: friend.y - size / 2,
                                            width: `${size}px`,
                                            height: `${size}px`,
                                            animation: `float ${5 + seededRandom(friend.id) * 3}s ease-in-out infinite`,
                                            animationDelay: `${seededRandom(friend.id + 50) * 2}s`,
                                        }}
                                    >
                                        {/* Glow */}
                                        <div style={{
                                            position: 'absolute',
                                            inset: '-10px',
                                            borderRadius: '50%',
                                            background: friend.color,
                                            filter: 'blur(14px)',
                                            opacity: isSelected ? 0.6 : isHighlighted ? 0.45 : glowOpacity,
                                            transition: 'opacity 0.3s ease',
                                            animation: 'glow 4s ease-in-out infinite',
                                            animationDelay: `${seededRandom(friend.id) * 2}s`,
                                        }} />

                                        {/* Star orb */}
                                        <div style={{
                                            position: 'relative',
                                            width: '100%',
                                            height: '100%',
                                            borderRadius: '50%',
                                            background: `radial-gradient(circle at 30% 30%, ${friend.color}, ${friend.color}99 60%, ${friend.color}66)`,
                                            display: 'flex',
                                            alignItems: 'center',
                                            justifyContent: 'center',
                                            fontSize: `${size * 0.38}px`,
                                            fontWeight: 700,
                                            border: isSelected ? '2px solid rgba(255,255,255,0.8)' : '1px solid rgba(255,255,255,0.1)',
                                            boxShadow: isSelected ? `0 0 20px ${friend.color}` : 'none',
                                            transition: 'all 0.2s ease',
                                        }}>
                                            {friend.initials}

                                            {/* Online indicator */}
                                            {friend.status === 'online' && (
                                                <div style={{
                                                    position: 'absolute',
                                                    bottom: '-2px',
                                                    right: '-2px',
                                                    width: '9px',
                                                    height: '9px',
                                                    borderRadius: '50%',
                                                    background: '#00D4AA',
                                                    border: '2px solid #0A0A10',
                                                    boxShadow: '0 0 6px #00D4AA',
                                                }} />
                                            )}
                                        </div>

                                        {/* Name label */}
                                        <span className="name-label" style={{ color: friend.color }}>
                                            {friend.name.split(' ')[0]}
                                        </span>
                                    </div>
                                );
                            })}
                        </div>

                        {/* Minimal Legend */}
                        <div style={{
                            display: 'flex',
                            justifyContent: 'center',
                            gap: '20px',
                            marginTop: '12px',
                            paddingTop: '12px',
                            borderTop: '1px solid rgba(255,255,255,0.03)',
                        }}>
                            <div style={{ display: 'flex', alignItems: 'center', gap: '6px' }}>
                                <div style={{
                                    width: '6px',
                                    height: '6px',
                                    borderRadius: '50%',
                                    background: '#00D4AA',
                                    boxShadow: '0 0 4px #00D4AA',
                                }} />
                                <span style={{ fontSize: '9px', color: 'rgba(255,255,255,0.35)', letterSpacing: '0.5px' }}>ONLINE</span>
                            </div>
                            <div style={{ display: 'flex', alignItems: 'center', gap: '6px' }}>
                                <div style={{ width: '14px', height: '1px', background: 'rgba(255,255,255,0.4)' }} />
                                <span style={{ fontSize: '9px', color: 'rgba(255,255,255,0.35)', letterSpacing: '0.5px' }}>COMPATIBLE</span>
                            </div>
                        </div>
                    </div>
                </div>

                {/* Selected Connection Detail Card */}
                {selectedConnection && (
                    <div className="glass-card" style={{
                        padding: '20px',
                        marginBottom: '20px',
                        borderLeft: `3px solid ${selectedConnection.color}`,
                        animation: 'fadeIn 0.2s ease',
                    }}>
                        <div style={{ display: 'flex', alignItems: 'center', gap: '14px', marginBottom: '16px' }}>
                            {/* Avatar */}
                            <div style={{
                                width: '52px',
                                height: '52px',
                                borderRadius: '50%',
                                background: `radial-gradient(circle at 30% 30%, ${selectedConnection.color}, ${selectedConnection.color}99)`,
                                display: 'flex',
                                alignItems: 'center',
                                justifyContent: 'center',
                                fontSize: '18px',
                                fontWeight: 700,
                                boxShadow: `0 0 25px ${selectedConnection.color}50`,
                            }}>
                                {selectedConnection.initials}
                            </div>

                            <div style={{ flex: 1 }}>
                                <div style={{ display: 'flex', alignItems: 'center', gap: '8px', marginBottom: '2px' }}>
                                    <h4 style={{ fontSize: '17px', fontWeight: 700, margin: 0 }}>{selectedConnection.name}</h4>
                                    {selectedConnection.status === 'online' && (
                                        <div style={{
                                            width: '8px',
                                            height: '8px',
                                            borderRadius: '50%',
                                            background: '#00D4AA',
                                            boxShadow: '0 0 6px #00D4AA',
                                        }} />
                                    )}
                                </div>
                                <p style={{
                                    fontSize: '12px',
                                    color: 'rgba(255,255,255,0.5)',
                                    margin: 0,
                                }}>{selectedConnection.sign} · {selectedConnection.lastAligned}</p>
                            </div>

                            <div style={{ textAlign: 'right' }}>
                                <div style={{
                                    fontSize: '28px',
                                    fontWeight: 800,
                                    color: getCompatibilityColor(selectedConnection.compatibility),
                                    lineHeight: 1,
                                }}>{selectedConnection.compatibility}%</div>
                                <span style={{ fontSize: '9px', color: 'rgba(255,255,255,0.4)', letterSpacing: '0.5px' }}>ALIGNED</span>
                            </div>
                        </div>

                        {/* Shared Planets */}
                        <div style={{ marginBottom: '16px' }}>
                            <p style={{
                                fontSize: '10px',
                                color: 'rgba(255,255,255,0.4)',
                                margin: '0 0 8px 0',
                                textTransform: 'uppercase',
                                letterSpacing: '1.5px',
                            }}>Shared Planets</p>
                            <div style={{ display: 'flex', gap: '8px', flexWrap: 'wrap' }}>
                                {selectedConnection.sharedPlanets.map((planet, i) => (
                                    <span key={i} style={{
                                        fontSize: '12px',
                                        color: 'rgba(255,255,255,0.8)',
                                        background: 'rgba(255,255,255,0.06)',
                                        padding: '6px 12px',
                                        borderRadius: '20px',
                                        display: 'flex',
                                        alignItems: 'center',
                                        gap: '6px',
                                        border: '1px solid rgba(255,255,255,0.08)',
                                    }}>
                                        <span style={{ color: selectedConnection.color, fontSize: '14px' }}>{getPlanetSymbol(planet)}</span>
                                        {planet}
                                    </span>
                                ))}
                            </div>
                        </div>

                        {/* Nearby Stars - now based on compatibility */}
                        {getConnectedFriends(selectedConnection.id).length > 0 && (
                            <div style={{ marginBottom: '16px' }}>
                                <p style={{
                                    fontSize: '10px',
                                    color: 'rgba(255,255,255,0.4)',
                                    margin: '0 0 8px 0',
                                    textTransform: 'uppercase',
                                    letterSpacing: '1.5px',
                                }}>Compatible With</p>
                                <div style={{ display: 'flex', gap: '8px' }}>
                                    {getConnectedFriends(selectedConnection.id).map((friend) => (
                                        <div
                                            key={friend.id}
                                            onClick={() => setSelectedConnection(friend)}
                                            style={{
                                                width: '32px',
                                                height: '32px',
                                                borderRadius: '50%',
                                                background: `radial-gradient(circle at 30% 30%, ${friend.color}, ${friend.color}99)`,
                                                display: 'flex',
                                                alignItems: 'center',
                                                justifyContent: 'center',
                                                fontSize: '11px',
                                                fontWeight: 700,
                                                cursor: 'pointer',
                                                border: '1px solid rgba(255,255,255,0.1)',
                                                transition: 'transform 0.2s ease',
                                            }}
                                            onMouseOver={(e) => e.currentTarget.style.transform = 'scale(1.1)'}
                                            onMouseOut={(e) => e.currentTarget.style.transform = 'scale(1)'}
                                        >
                                            {friend.initials}
                                        </div>
                                    ))}
                                </div>
                            </div>
                        )}

                        {/* Action Buttons */}
                        <div style={{ display: 'flex', gap: '10px' }}>
                            <button style={{
                                flex: 1,
                                background: 'rgba(255, 255, 255, 0.05)',
                                border: '1px solid rgba(255, 255, 255, 0.1)',
                                borderRadius: '14px',
                                padding: '14px',
                                color: 'white',
                                fontFamily: "'Syne', sans-serif",
                                fontWeight: 600,
                                fontSize: '13px',
                                cursor: 'pointer',
                                display: 'flex',
                                alignItems: 'center',
                                justifyContent: 'center',
                                gap: '8px',
                                transition: 'all 0.2s ease',
                            }}>
                                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                                    <path d="M20 21v-2a4 4 0 00-4-4H8a4 4 0 00-4 4v2" />
                                    <circle cx="12" cy="7" r="4" />
                                </svg>
                                Profile
                            </button>
                            <button style={{
                                flex: 1,
                                background: `linear-gradient(135deg, ${selectedConnection.color} 0%, ${selectedConnection.color}bb 100%)`,
                                border: 'none',
                                borderRadius: '14px',
                                padding: '14px',
                                color: 'white',
                                fontFamily: "'Syne', sans-serif",
                                fontWeight: 600,
                                fontSize: '13px',
                                cursor: 'pointer',
                                display: 'flex',
                                alignItems: 'center',
                                justifyContent: 'center',
                                gap: '8px',
                                boxShadow: `0 4px 20px ${selectedConnection.color}40`,
                                transition: 'all 0.2s ease',
                            }}>
                                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                                    <circle cx="12" cy="12" r="10" />
                                    <path d="M12 6v6l4 2" />
                                </svg>
                                Align Now
                            </button>
                        </div>
                    </div>
                )}

                {/* Spacer */}
                <div style={{ height: '100px' }} />

                {/* Bottom Navigation */}
                <div style={{
                    position: 'fixed',
                    bottom: 0,
                    left: '50%',
                    transform: 'translateX(-50%)',
                    width: '100%',
                    maxWidth: '420px',
                    padding: '0 20px 20px',
                    boxSizing: 'border-box',
                }}>
                    <div className="glass-card" style={{
                        display: 'flex',
                        justifyContent: 'space-around',
                        alignItems: 'center',
                        padding: '14px 8px',
                    }}>
                        {[
                            { id: 'home', icon: 'M3 12L12 3L21 12V21H3V12Z', label: 'Home' },
                            { id: 'sound', icon: 'M12 2C13.1 2 14 2.9 14 4V12C14 13.1 13.1 14 12 14C10.9 14 10 13.1 10 12V4C10 2.9 10.9 2 12 2ZM6 10V12C6 15.3 8.7 18 12 18C15.3 18 18 15.3 18 12V10M12 18V22M8 22H16', label: 'Sound' },
                            { id: 'connections', icon: 'M12 2L2 7L12 12L22 7L12 2ZM2 17L12 22L22 17M2 12L12 17L22 12', label: 'Connect' },
                            { id: 'calendar', icon: 'M8 7V3M16 7V3M7 11H17M5 21H19C20.1 21 21 20.1 21 19V7C21 5.9 20.1 5 19 5H5C3.9 5 3 5.9 3 7V19C3 20.1 3.9 21 5 21Z', label: 'Calendar' },
                            { id: 'profile', icon: 'M20 21V19C20 17.9 19.55 16.88 18.83 16.17C18.1 15.45 17.11 15 16 15H8C6.89 15 5.9 15.45 5.17 16.17C4.45 16.88 4 17.9 4 19V21M12 11C14.21 11 16 9.21 16 7C16 4.79 14.21 3 12 3C9.79 3 8 4.79 8 7C8 9.21 9.79 11 12 11Z', label: 'Profile' },
                        ].map((item) => (
                            <div
                                key={item.id}
                                className="nav-item"
                                onClick={() => setActiveTab(item.id)}
                                style={{
                                    display: 'flex',
                                    flexDirection: 'column',
                                    alignItems: 'center',
                                    gap: '4px',
                                    cursor: 'pointer',
                                    padding: '6px 10px',
                                }}
                            >
                                <svg
                                    width="22"
                                    height="22"
                                    viewBox="0 0 24 24"
                                    fill="none"
                                    style={{
                                        stroke: activeTab === item.id ? '#FAFF0E' : 'rgba(255, 255, 255, 0.5)',
                                        strokeWidth: 2,
                                        strokeLinecap: 'round',
                                        strokeLinejoin: 'round',
                                    }}
                                >
                                    <path d={item.icon} />
                                </svg>
                                <span style={{
                                    fontSize: '9px',
                                    fontWeight: activeTab === item.id ? 600 : 400,
                                    color: activeTab === item.id ? '#FAFF0E' : 'rgba(255, 255, 255, 0.5)',
                                    textTransform: 'uppercase',
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

export default ConnectionsConstellationV4;