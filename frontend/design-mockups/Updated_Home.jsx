import React, { useState } from 'react';

const HomeScreenV2 = () => {
    const [activeTab, setActiveTab] = useState('home');
    const [isPlaying, setIsPlaying] = useState(false);
    const [expandedReading, setExpandedReading] = useState(0);

    const currentSeason = {
        sign: "Capricorn",
        element: "Earth",
        dateRange: "Dec 22 - Jan 19",
        symbol: "♑",
    };

    const readings = [
        {
            type: "RESONANCE",
            category: "Self",
            icon: "✓",
            iconColor: "#00D4AA",
            message: "Your Aries Sun is broadcasting clearly. Signal is stable.",
        },
        {
            type: "FEEDBACK",
            category: "Communication",
            icon: "⚠",
            iconColor: "#FAFF0E",
            message: "Watch the gain on your words today. Easy to clip.",
        },
        {
            type: "DISSONANCE",
            category: "Work & Career",
            icon: "✕",
            iconColor: "#E84855",
            message: "Some static in your focus. Low-pass filter out the noise.",
        },
    ];

    const tracks = [
        { id: 1, title: "About Damn Time", artist: "Lizzo", genre: "Hip Hop", duration: "3:11", mood: "Upbeat", moodIcon: "⚡", moodColor: "#FAFF0E" },
        { id: 2, title: "Çam Kolonyası", artist: "Onur Akın", genre: "World", duration: "4:54", mood: "Groovy", moodIcon: "♪", moodColor: "#FF59D0" },
        { id: 3, title: "Pepas", artist: "Farruko", genre: "Latin", duration: "4:47", mood: "Upbeat", moodIcon: "⚡", moodColor: "#FAFF0E" },
        { id: 4, title: "Limbo", artist: "Daddy Yankee", genre: "Latin", duration: "3:44", mood: "Upbeat", moodIcon: "⚡", moodColor: "#FAFF0E" },
        { id: 5, title: "Dissolve", artist: "Kiasmos", genre: "Ambient", duration: "7:03", mood: "Dreamy", moodIcon: "◐", moodColor: "#7D67FE" },
        { id: 6, title: "Midnight Hour", artist: "Skrillex", genre: "Electronic", duration: "5:22", mood: "Intense", moodIcon: "◈", moodColor: "#E84855" },
    ];

    const queueStats = {
        trackCount: 20,
        duration: "1h 14m",
        status: "Ready",
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
        
        @keyframes float {
          0%, 100% { transform: translateY(0); }
          50% { transform: translateY(-12px); }
        }
        
        @keyframes pulse {
          0%, 100% { opacity: 0.4; transform: scale(1); }
          50% { opacity: 0.7; transform: scale(1.05); }
        }
        
        @keyframes orbGlow {
          0%, 100% { 
            box-shadow: 
              0 0 60px rgba(255, 89, 208, 0.4),
              0 0 120px rgba(125, 103, 254, 0.2);
          }
          50% { 
            box-shadow: 
              0 0 80px rgba(255, 89, 208, 0.5),
              0 0 150px rgba(125, 103, 254, 0.3);
          }
        }
        
        @keyframes waveform {
          0%, 100% { transform: scaleY(0.4); }
          50% { transform: scaleY(1); }
        }
        
        @keyframes rotate {
          from { transform: rotate(0deg); }
          to { transform: rotate(360deg); }
        }
        
        @keyframes shimmer {
          0% { background-position: -200% center; }
          100% { background-position: 200% center; }
        }
        
        .hide-scrollbar::-webkit-scrollbar {
          display: none;
        }
        
        .glass-card {
          background: rgba(255, 255, 255, 0.03);
          backdrop-filter: blur(20px);
          -webkit-backdrop-filter: blur(20px);
          border: 1px solid rgba(255, 255, 255, 0.06);
          border-radius: 20px;
        }
        
        .hero-orb {
          animation: float 6s ease-in-out infinite, orbGlow 4s ease-in-out infinite;
        }
        
        .hero-orb.playing {
          animation: float 6s ease-in-out infinite, orbGlow 2s ease-in-out infinite;
        }
        
        .orb-ring {
          animation: rotate 20s linear infinite;
        }
        
        .track-item {
          transition: all 0.2s ease;
        }
        
        .track-item:active {
          background: rgba(255, 255, 255, 0.06);
          transform: scale(0.98);
        }
        
        .cta-button {
          transition: all 0.2s ease;
        }
        
        .cta-button:active {
          transform: scale(0.96);
        }
        
        .reading-card {
          transition: all 0.3s ease;
        }
        
        .reading-dot {
          transition: all 0.2s ease;
        }
        
        .nav-item {
          transition: all 0.2s ease;
        }
        
        .nav-item:active {
          transform: scale(0.9);
        }

        /* Flutter-friendly: avoid pseudo-elements where possible */
        /* Use actual elements for all visual components */
      `}</style>

            {/* Background Gradient Blobs */}
            <div style={{
                position: 'absolute',
                top: '-5%',
                left: '50%',
                transform: 'translateX(-50%)',
                width: '400px',
                height: '400px',
                background: 'radial-gradient(circle, rgba(255, 89, 208, 0.15) 0%, transparent 60%)',
                borderRadius: '50%',
                filter: 'blur(60px)',
                animation: 'pulse 8s ease-in-out infinite',
                pointerEvents: 'none',
            }} />
            <div style={{
                position: 'absolute',
                top: '40%',
                right: '-20%',
                width: '300px',
                height: '300px',
                background: 'radial-gradient(circle, rgba(125, 103, 254, 0.1) 0%, transparent 60%)',
                borderRadius: '50%',
                filter: 'blur(60px)',
                animation: 'pulse 10s ease-in-out infinite 2s',
                pointerEvents: 'none',
            }} />

            {/* Main Container - max width for mobile */}
            <div style={{
                maxWidth: '420px',
                margin: '0 auto',
                padding: '0 20px',
                position: 'relative',
                zIndex: 10,
                paddingBottom: '100px',
            }}>

                {/* Status Bar */}
                <div style={{
                    display: 'flex',
                    justifyContent: 'space-between',
                    alignItems: 'center',
                    padding: '14px 4px',
                    fontSize: '14px',
                    fontFamily: "'Space Grotesk', sans-serif",
                    fontWeight: 500,
                }}>
                    <span>9:41</span>
                    <div style={{ display: 'flex', gap: '6px', alignItems: 'center' }}>
                        <svg width="18" height="12" viewBox="0 0 18 12" fill="white">
                            <path d="M1 4C1 3.45 1.45 3 2 3H3C3.55 3 4 3.45 4 4V11C4 11.55 3.55 12 3 12H2C1.45 12 1 11.55 1 11V4Z" fillOpacity="0.4" />
                            <path d="M5 3C5 2.45 5.45 2 6 2H7C7.55 2 8 2.45 8 3V11C8 11.55 7.55 12 7 12H6C5.45 12 5 11.55 5 11V3Z" fillOpacity="0.6" />
                            <path d="M9 1C9 0.45 9.45 0 10 0H11C11.55 0 12 0.45 12 1V11C12 11.55 11.55 12 11 12H10C9.45 12 9 11.55 9 11V1Z" />
                            <path d="M13 2C13 1.45 13.45 1 14 1H15C15.55 1 16 1.45 16 2V11C16 11.55 15.55 12 15 12H14C13.45 12 13 11.55 13 11V2Z" />
                        </svg>
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
                    padding: '8px 0 24px',
                }}>
                    <button style={{
                        background: 'rgba(255, 255, 255, 0.05)',
                        border: '1px solid rgba(255, 255, 255, 0.08)',
                        borderRadius: '12px',
                        padding: '10px',
                        cursor: 'pointer',
                        display: 'flex',
                        alignItems: 'center',
                        justifyContent: 'center',
                    }}>
                        <svg width="20" height="14" viewBox="0 0 20 14" fill="none">
                            <path d="M1 1H19M1 7H19M1 13H13" stroke="white" strokeWidth="2" strokeLinecap="round" />
                        </svg>
                    </button>

                    {/* Logo */}
                    <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
                        <div style={{
                            width: '36px',
                            height: '36px',
                            position: 'relative',
                        }}>
                            <div style={{
                                width: '100%',
                                height: '100%',
                                borderRadius: '50%',
                                border: '2.5px solid #FAFF0E',
                                position: 'relative',
                            }}>
                                <div style={{
                                    position: 'absolute',
                                    top: '50%',
                                    left: '50%',
                                    transform: 'translate(-50%, -50%) rotate(-20deg)',
                                    width: '130%',
                                    height: '10px',
                                    border: '2.5px solid #FF59D0',
                                    borderRadius: '50%',
                                }} />
                            </div>
                        </div>
                        <span style={{
                            fontWeight: 800,
                            fontSize: '20px',
                            letterSpacing: '-0.5px',
                            background: 'linear-gradient(90deg, #FFFFFF 0%, rgba(255,255,255,0.9) 100%)',
                            WebkitBackgroundClip: 'text',
                            WebkitTextFillColor: 'transparent',
                        }}>ASTRO.FM</span>
                    </div>

                    <button style={{
                        background: 'rgba(255, 255, 255, 0.05)',
                        border: '1px solid rgba(255, 255, 255, 0.08)',
                        borderRadius: '12px',
                        padding: '10px',
                        cursor: 'pointer',
                        display: 'flex',
                        alignItems: 'center',
                        justifyContent: 'center',
                    }}>
                        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="white" strokeWidth="2">
                            <circle cx="12" cy="12" r="3" />
                            <path d="M12 1v2M12 21v2M4.22 4.22l1.42 1.42M18.36 18.36l1.42 1.42M1 12h2M21 12h2M4.22 19.78l1.42-1.42M18.36 5.64l1.42-1.42" />
                        </svg>
                    </button>
                </div>

                {/* Hero Section - Today's Sound Orb */}
                <div style={{
                    display: 'flex',
                    flexDirection: 'column',
                    alignItems: 'center',
                    marginBottom: '20px',
                }}>
                    {/* Main Orb - Compact 140px */}
                    <div
                        className={`hero-orb ${isPlaying ? 'playing' : ''}`}
                        onClick={() => setIsPlaying(!isPlaying)}
                        style={{
                            width: '140px',
                            height: '140px',
                            borderRadius: '50%',
                            background: 'linear-gradient(135deg, #FF59D0 0%, #C44BAD 30%, #7D67FE 70%, #5B4BC4 100%)',
                            position: 'relative',
                            cursor: 'pointer',
                            display: 'flex',
                            alignItems: 'center',
                            justifyContent: 'center',
                            marginBottom: '14px',
                        }}
                    >
                        {/* Single Orbital Ring */}
                        <div
                            className="orb-ring"
                            style={{
                                position: 'absolute',
                                width: '170px',
                                height: '170px',
                                borderRadius: '50%',
                                border: '1px solid rgba(255, 255, 255, 0.1)',
                            }}
                        />

                        {/* Inner Content - Waveform or Play Icon */}
                        <div style={{
                            display: 'flex',
                            flexDirection: 'column',
                            alignItems: 'center',
                        }}>
                            {isPlaying ? (
                                <div style={{ display: 'flex', gap: '3px', alignItems: 'center', height: '36px' }}>
                                    {[0.3, 0.6, 1, 0.7, 0.5, 0.8, 0.4].map((h, i) => (
                                        <div key={i} style={{
                                            width: '4px',
                                            height: '36px',
                                            background: 'rgba(255,255,255,0.9)',
                                            borderRadius: '2px',
                                            animation: `waveform ${0.4 + i * 0.1}s ease-in-out infinite`,
                                            animationDelay: `${i * 0.05}s`,
                                            transformOrigin: 'center',
                                        }} />
                                    ))}
                                </div>
                            ) : (
                                <svg width="36" height="36" viewBox="0 0 24 24" fill="rgba(255,255,255,0.9)">
                                    <polygon points="6,4 20,12 6,20" />
                                </svg>
                            )}
                        </div>
                    </div>

                    {/* Labels */}
                    <p style={{
                        fontSize: '11px',
                        color: 'rgba(255,255,255,0.5)',
                        textTransform: 'uppercase',
                        letterSpacing: '2px',
                        margin: '0 0 4px 0',
                        fontFamily: "'Space Grotesk', sans-serif",
                    }}>Today's Sound</p>
                    <p style={{
                        fontSize: '13px',
                        color: isPlaying ? '#FAFF0E' : 'rgba(255,255,255,0.6)',
                        margin: 0,
                        fontWeight: 500,
                    }}>{isPlaying ? 'Now Playing' : 'Tap to Play'}</p>
                </div>

                {/* Season Pill - Tappable to open horoscope */}
                <div style={{
                    display: 'flex',
                    justifyContent: 'center',
                    marginBottom: '20px',
                }}>
                    <button
                        onClick={() => {/* Open horoscope bottom sheet */ }}
                        style={{
                            display: 'flex',
                            alignItems: 'center',
                            gap: '10px',
                            background: 'rgba(255, 255, 255, 0.04)',
                            border: '1px solid rgba(255, 255, 255, 0.08)',
                            borderRadius: '100px',
                            padding: '8px 16px 8px 8px',
                            cursor: 'pointer',
                            transition: 'all 0.2s ease',
                        }}
                    >
                        <div style={{
                            width: '32px',
                            height: '32px',
                            borderRadius: '50%',
                            background: 'linear-gradient(135deg, #7D67FE 0%, #5B4BC4 100%)',
                            display: 'flex',
                            alignItems: 'center',
                            justifyContent: 'center',
                            fontSize: '15px',
                        }}>
                            {currentSeason.symbol}
                        </div>
                        <div style={{ textAlign: 'left' }}>
                            <p style={{
                                fontSize: '13px',
                                fontWeight: 600,
                                margin: 0,
                                color: 'white',
                                display: 'flex',
                                alignItems: 'center',
                                gap: '6px',
                            }}>
                                {currentSeason.sign} Season
                                <span style={{
                                    fontSize: '10px',
                                    fontWeight: 600,
                                    color: '#00D4AA',
                                    background: 'rgba(0, 212, 170, 0.15)',
                                    padding: '2px 6px',
                                    borderRadius: '4px',
                                }}>{currentSeason.element}</span>
                            </p>
                        </div>
                        {/* Chevron indicator */}
                        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="rgba(255,255,255,0.4)" strokeWidth="2">
                            <polyline points="6 9 12 15 18 9" />
                        </svg>
                    </button>
                </div>

                {/* CTA Buttons */}
                <div style={{
                    display: 'flex',
                    gap: '12px',
                    marginBottom: '32px',
                }}>
                    <button className="cta-button" style={{
                        flex: 1,
                        background: 'linear-gradient(135deg, #7D67FE 0%, #5B4BC4 100%)',
                        border: 'none',
                        borderRadius: '16px',
                        padding: '18px 20px',
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
                        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                            <circle cx="12" cy="12" r="10" />
                            <path d="M12 6v6l4 2" />
                        </svg>
                        Align Now
                    </button>

                    <button className="cta-button" style={{
                        flex: 1,
                        background: 'linear-gradient(135deg, #FAFF0E 0%, #D4D900 100%)',
                        border: 'none',
                        borderRadius: '16px',
                        padding: '18px 20px',
                        fontSize: '14px',
                        fontWeight: 700,
                        fontFamily: "'Syne', sans-serif",
                        color: '#0A0A0F',
                        cursor: 'pointer',
                        display: 'flex',
                        alignItems: 'center',
                        justifyContent: 'center',
                        gap: '10px',
                        boxShadow: '0 8px 24px rgba(250, 255, 14, 0.25)',
                    }}>
                        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5">
                            <path d="M9 18V5l12-2v13" />
                            <circle cx="6" cy="18" r="3" />
                            <circle cx="18" cy="16" r="3" />
                        </svg>
                        Generate
                    </button>
                </div>

                {/* Today's Reading - Horizontal Swipe Carousel */}
                <div style={{ marginBottom: '24px' }}>
                    <div style={{
                        display: 'flex',
                        justifyContent: 'space-between',
                        alignItems: 'center',
                        marginBottom: '12px',
                        padding: '0 4px',
                    }}>
                        <h3 style={{
                            fontSize: '12px',
                            fontWeight: 600,
                            margin: 0,
                            color: 'rgba(255,255,255,0.5)',
                            textTransform: 'uppercase',
                            letterSpacing: '1.5px',
                        }}>Today's Reading</h3>

                        {/* Pagination Dots */}
                        <div style={{ display: 'flex', gap: '5px' }}>
                            {readings.map((_, i) => (
                                <div
                                    key={i}
                                    className="reading-dot"
                                    style={{
                                        width: expandedReading === i ? '16px' : '5px',
                                        height: '5px',
                                        borderRadius: '3px',
                                        background: expandedReading === i ? '#FAFF0E' : 'rgba(255,255,255,0.2)',
                                        transition: 'all 0.2s ease',
                                    }}
                                />
                            ))}
                        </div>
                    </div>

                    {/* Horizontal Scroll Container - PageView in Flutter */}
                    <div style={{
                        display: 'flex',
                        gap: '12px',
                        overflowX: 'auto',
                        scrollSnapType: 'x mandatory',
                        WebkitOverflowScrolling: 'touch',
                        marginLeft: '-20px',
                        marginRight: '-20px',
                        paddingLeft: '20px',
                        paddingRight: '20px',
                        scrollbarWidth: 'none',
                        msOverflowStyle: 'none',
                    }}
                        className="hide-scrollbar"
                        onScroll={(e) => {
                            const scrollLeft = e.target.scrollLeft;
                            const cardWidth = 292;
                            const newIndex = Math.round(scrollLeft / cardWidth);
                            if (newIndex !== expandedReading && newIndex >= 0 && newIndex < readings.length) {
                                setExpandedReading(newIndex);
                            }
                        }}
                    >
                        {readings.map((reading, index) => (
                            <div
                                key={index}
                                className="glass-card reading-card"
                                style={{
                                    minWidth: '280px',
                                    maxWidth: '280px',
                                    padding: '16px',
                                    borderLeft: `3px solid ${reading.iconColor}`,
                                    scrollSnapAlign: 'start',
                                    flexShrink: 0,
                                }}
                            >
                                <div style={{
                                    display: 'flex',
                                    justifyContent: 'space-between',
                                    alignItems: 'center',
                                    marginBottom: '10px',
                                }}>
                                    <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                                        <div style={{
                                            width: '24px',
                                            height: '24px',
                                            borderRadius: '6px',
                                            background: `${reading.iconColor}20`,
                                            display: 'flex',
                                            alignItems: 'center',
                                            justifyContent: 'center',
                                            fontSize: '12px',
                                            color: reading.iconColor,
                                            fontWeight: 700,
                                        }}>
                                            {reading.icon}
                                        </div>
                                        <span style={{
                                            fontSize: '11px',
                                            fontWeight: 700,
                                            color: reading.iconColor,
                                            textTransform: 'uppercase',
                                            letterSpacing: '1px',
                                        }}>{reading.type}</span>
                                    </div>
                                    <span style={{
                                        fontSize: '11px',
                                        color: 'rgba(255,255,255,0.4)',
                                        fontFamily: "'Space Grotesk', sans-serif",
                                    }}>{reading.category}</span>
                                </div>
                                <p style={{
                                    fontSize: '13px',
                                    lineHeight: '1.5',
                                    color: 'rgba(255,255,255,0.8)',
                                    margin: 0,
                                    fontFamily: "'Space Grotesk', sans-serif",
                                }}>{reading.message}</p>
                            </div>
                        ))}
                    </div>
                </div>

                {/* Cosmic Queue */}
                <div>
                    <div style={{
                        display: 'flex',
                        justifyContent: 'space-between',
                        alignItems: 'center',
                        marginBottom: '14px',
                        padding: '0 4px',
                    }}>
                        <div>
                            <h3 style={{
                                fontSize: '18px',
                                fontWeight: 700,
                                margin: '0 0 4px 0',
                            }}>Your Cosmic Queue</h3>
                            <p style={{
                                fontSize: '13px',
                                color: 'rgba(255,255,255,0.5)',
                                margin: 0,
                                fontFamily: "'Space Grotesk', sans-serif",
                            }}>{queueStats.trackCount} tracks • {queueStats.duration}</p>
                        </div>
                        <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
                            <div style={{
                                display: 'flex',
                                alignItems: 'center',
                                gap: '6px',
                                background: 'rgba(0, 212, 170, 0.15)',
                                padding: '6px 12px',
                                borderRadius: '20px',
                            }}>
                                <div style={{
                                    width: '8px',
                                    height: '8px',
                                    borderRadius: '50%',
                                    background: '#00D4AA',
                                }} />
                                <span style={{
                                    fontSize: '12px',
                                    color: '#00D4AA',
                                    fontWeight: 600,
                                }}>{queueStats.status}</span>
                            </div>
                            <span style={{
                                fontSize: '13px',
                                color: '#FF59D0',
                                fontWeight: 600,
                                cursor: 'pointer',
                            }}>See All</span>
                        </div>
                    </div>

                    {/* Track List */}
                    <div className="glass-card" style={{ padding: '8px', overflow: 'hidden' }}>
                        {tracks.map((track, index) => (
                            <div
                                key={track.id}
                                className="track-item"
                                style={{
                                    display: 'flex',
                                    alignItems: 'center',
                                    gap: '14px',
                                    padding: '14px 12px',
                                    borderRadius: '14px',
                                    cursor: 'pointer',
                                    borderBottom: index < tracks.length - 1 ? '1px solid rgba(255,255,255,0.04)' : 'none',
                                }}
                            >
                                {/* Track Number */}
                                <div style={{
                                    width: '28px',
                                    textAlign: 'center',
                                    flexShrink: 0,
                                }}>
                                    <span style={{
                                        fontSize: '14px',
                                        fontWeight: 600,
                                        color: 'rgba(255,255,255,0.4)',
                                        fontFamily: "'Space Grotesk', sans-serif",
                                    }}>{index + 1}</span>
                                </div>

                                {/* Track Info */}
                                <div style={{ flex: 1, minWidth: 0 }}>
                                    <p style={{
                                        fontSize: '15px',
                                        fontWeight: 600,
                                        margin: '0 0 4px 0',
                                        whiteSpace: 'nowrap',
                                        overflow: 'hidden',
                                        textOverflow: 'ellipsis',
                                    }}>{track.title}</p>
                                    <div style={{
                                        display: 'flex',
                                        alignItems: 'center',
                                        gap: '8px',
                                    }}>
                                        <span style={{
                                            fontSize: '13px',
                                            color: 'rgba(255,255,255,0.5)',
                                            fontFamily: "'Space Grotesk', sans-serif",
                                        }}>{track.artist}</span>
                                        <span style={{
                                            fontSize: '11px',
                                            color: 'rgba(255,255,255,0.4)',
                                            background: 'rgba(255,255,255,0.06)',
                                            padding: '2px 8px',
                                            borderRadius: '6px',
                                            fontFamily: "'Space Grotesk', sans-serif",
                                        }}>{track.genre}</span>
                                    </div>
                                </div>

                                {/* Duration */}
                                <span style={{
                                    fontSize: '13px',
                                    color: 'rgba(255,255,255,0.4)',
                                    fontFamily: "'Space Grotesk', sans-serif",
                                    marginRight: '8px',
                                }}>{track.duration}</span>

                                {/* Mood Icon & Label */}
                                <div style={{
                                    display: 'flex',
                                    alignItems: 'center',
                                    gap: '6px',
                                    background: `${track.moodColor}15`,
                                    padding: '6px 12px',
                                    borderRadius: '20px',
                                    flexShrink: 0,
                                }}>
                                    <span style={{
                                        fontSize: '14px',
                                        color: track.moodColor,
                                    }}>{track.moodIcon}</span>
                                    <span style={{
                                        fontSize: '11px',
                                        fontWeight: 600,
                                        color: track.moodColor,
                                    }}>{track.mood}</span>
                                </div>
                            </div>
                        ))}
                    </div>
                </div>

                {/* Spacer for bottom nav */}
                <div style={{ height: '20px' }} />
            </div>

            {/* Bottom Navigation - Fixed */}
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
                        {
                            id: 'home', label: 'HOME', icon: (
                                <svg width="22" height="22" viewBox="0 0 24 24" fill="none" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                                    <path d="M3 9l9-7 9 7v11a2 2 0 01-2 2H5a2 2 0 01-2-2z" />
                                    <polyline points="9 22 9 12 15 12 15 22" />
                                </svg>
                            )
                        },
                        {
                            id: 'sound', label: 'SOUND', icon: (
                                <svg width="22" height="22" viewBox="0 0 24 24" fill="none" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                                    <path d="M12 2a3 3 0 00-3 3v7a3 3 0 006 0V5a3 3 0 00-3-3z" />
                                    <path d="M19 10v2a7 7 0 01-14 0v-2" />
                                    <line x1="12" y1="19" x2="12" y2="22" />
                                </svg>
                            )
                        },
                        {
                            id: 'align', label: 'ALIGN', icon: (
                                <svg width="24" height="24" viewBox="0 0 24 24" fill="none" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                                    <polygon points="12 2 2 7 12 12 22 7 12 2" />
                                    <polyline points="2 17 12 22 22 17" />
                                    <polyline points="2 12 12 17 22 12" />
                                </svg>
                            )
                        },
                        {
                            id: 'friends', label: 'FRIENDS', icon: (
                                <svg width="22" height="22" viewBox="0 0 24 24" fill="none" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                                    <path d="M17 21v-2a4 4 0 00-4-4H5a4 4 0 00-4 4v2" />
                                    <circle cx="9" cy="7" r="4" />
                                    <path d="M23 21v-2a4 4 0 00-3-3.87" />
                                    <path d="M16 3.13a4 4 0 010 7.75" />
                                </svg>
                            )
                        },
                        {
                            id: 'profile', label: 'PROFILE', icon: (
                                <svg width="22" height="22" viewBox="0 0 24 24" fill="none" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                                    <path d="M20 21v-2a4 4 0 00-4-4H8a4 4 0 00-4 4v2" />
                                    <circle cx="12" cy="7" r="4" />
                                </svg>
                            )
                        },
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
                                padding: '8px 12px',
                            }}
                        >
                            <div style={{
                                stroke: activeTab === item.id ? '#FAFF0E' : 'rgba(255, 255, 255, 0.4)',
                            }}>
                                {React.cloneElement(item.icon, {
                                    style: { stroke: activeTab === item.id ? '#FAFF0E' : 'rgba(255, 255, 255, 0.4)' }
                                })}
                            </div>
                            <span style={{
                                fontSize: '9px',
                                fontWeight: activeTab === item.id ? 700 : 500,
                                color: activeTab === item.id ? '#FAFF0E' : 'rgba(255, 255, 255, 0.4)',
                                letterSpacing: '0.5px',
                            }}>{item.label}</span>
                        </div>
                    ))}
                </div>
            </div>
        </div>
    );
};

export default HomeScreenV2;