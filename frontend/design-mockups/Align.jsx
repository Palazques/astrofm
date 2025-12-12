import React, { useState, useEffect } from 'react';

const Align = () => {
  const [activeTab, setActiveTab] = useState('align');
  const [alignTarget, setAlignTarget] = useState('today'); // 'today', 'friend', 'transit'
  const [isAligning, setIsAligning] = useState(false);
  const [alignmentProgress, setAlignmentProgress] = useState(0);
  const [resonanceScore, setResonanceScore] = useState(0);
  const [selectedFriend, setSelectedFriend] = useState(null);

  const friends = [
    { id: 1, name: "Maya", color1: "#FF59D0", color2: "#7D67FE", compatibility: 87 },
    { id: 2, name: "Jordan", color1: "#FAFF0E", color2: "#FF59D0", compatibility: 72 },
    { id: 3, name: "Alex", color1: "#7D67FE", color2: "#00D4AA", compatibility: 91 },
    { id: 4, name: "Sam", color1: "#00D4AA", color2: "#FAFF0E", compatibility: 65 },
  ];

  const upcomingTransits = [
    { id: 1, name: "Full Moon in Cancer", date: "Dec 15", energy: "Emotional Release" },
    { id: 2, name: "Mercury enters Capricorn", date: "Dec 18", energy: "Structured Thinking" },
  ];

  // Simulate alignment animation
  useEffect(() => {
    if (isAligning && alignmentProgress < 100) {
      const timer = setTimeout(() => {
        setAlignmentProgress(prev => Math.min(prev + 2, 100));
      }, 50);
      return () => clearTimeout(timer);
    } else if (alignmentProgress >= 100 && isAligning) {
      setIsAligning(false);
      setResonanceScore(alignTarget === 'today' ? 78 : selectedFriend?.compatibility || 75);
    }
  }, [isAligning, alignmentProgress, alignTarget, selectedFriend]);

  const startAlignment = () => {
    setIsAligning(true);
    setAlignmentProgress(0);
    setResonanceScore(0);
  };

  const resetAlignment = () => {
    setAlignmentProgress(0);
    setResonanceScore(0);
    setIsAligning(false);
  };

  const getTargetOrb = () => {
    if (alignTarget === 'today') {
      return { color1: '#FAFF0E', color2: '#FF59D0', color3: '#7D67FE', label: "Today's Sound", sublabel: 'Cosmic Frequency' };
    } else if (alignTarget === 'friend' && selectedFriend) {
      return { color1: selectedFriend.color1, color2: selectedFriend.color2, color3: selectedFriend.color1, label: selectedFriend.name, sublabel: 'Personal Frequency' };
    }
    return { color1: '#7D67FE', color2: '#FF59D0', color3: '#FAFF0E', label: 'Select Target', sublabel: 'Choose below' };
  };

  const targetOrb = getTargetOrb();

  return (
    <div style={{
      minHeight: '100vh',
      background: 'linear-gradient(180deg, #0A0A0F 0%, #0D0D15 50%, #12101A 100%)',
      fontFamily: "'Syne', sans-serif",
      color: '#FFFFFF',
      position: 'relative',
      overflow: 'hidden',
    }}>
      <style>{`
        @import url('https://fonts.googleapis.com/css2?family=Syne:wght@400;500;600;700;800&family=Space+Grotesk:wght@300;400;500&display=swap');
        
        @keyframes float {
          0%, 100% { transform: translateY(0); }
          50% { transform: translateY(-10px); }
        }
        
        @keyframes pulse {
          0%, 100% { opacity: 0.6; transform: scale(1); }
          50% { opacity: 1; transform: scale(1.05); }
        }
        
        @keyframes orbGlow {
          0%, 100% { filter: blur(20px) brightness(1); }
          50% { filter: blur(25px) brightness(1.2); }
        }
        
        @keyframes waveform {
          0%, 100% { transform: scaleY(1); }
          50% { transform: scaleY(1.4); }
        }
        
        @keyframes merge {
          0% { transform: translateX(0); }
          50% { transform: translateX(20px); }
          100% { transform: translateX(0); }
        }
        
        @keyframes mergeRight {
          0% { transform: translateX(0); }
          50% { transform: translateX(-20px); }
          100% { transform: translateX(0); }
        }
        
        @keyframes ripple {
          0% { transform: scale(1); opacity: 1; }
          100% { transform: scale(2); opacity: 0; }
        }
        
        @keyframes rotateRing {
          0% { transform: rotate(0deg); }
          100% { transform: rotate(360deg); }
        }
        
        .glass-card {
          background: rgba(255, 255, 255, 0.03);
          backdrop-filter: blur(20px);
          -webkit-backdrop-filter: blur(20px);
          border: 1px solid rgba(255, 255, 255, 0.08);
          border-radius: 24px;
        }
        
        .orb {
          position: relative;
          width: 120px;
          height: 120px;
          border-radius: 50%;
          animation: float 6s ease-in-out infinite;
        }
        
        .orb.aligning {
          animation: merge 2s ease-in-out infinite;
        }
        
        .orb.aligning-target {
          animation: mergeRight 2s ease-in-out infinite;
        }
        
        .orb::before {
          content: '';
          position: absolute;
          inset: -15px;
          border-radius: 50%;
          background: inherit;
          filter: blur(25px);
          opacity: 0.6;
          animation: orbGlow 4s ease-in-out infinite;
        }
        
        .orb-inner {
          position: absolute;
          inset: 0;
          border-radius: 50%;
          overflow: hidden;
          display: flex;
          align-items: center;
          justify-content: center;
        }
        
        .orb-ring {
          position: absolute;
          border: 1px solid rgba(255, 255, 255, 0.2);
          border-radius: 50%;
          animation: rotateRing 20s linear infinite;
        }
        
        .tab-button {
          flex: 1;
          padding: 12px 16px;
          background: transparent;
          border: none;
          color: rgba(255, 255, 255, 0.5);
          font-family: 'Syne', sans-serif;
          font-size: 13px;
          font-weight: 600;
          cursor: pointer;
          transition: all 0.3s ease;
          border-radius: 12px;
        }
        
        .tab-button.active {
          background: rgba(255, 255, 255, 0.1);
          color: #FAFF0E;
        }
        
        .friend-item {
          transition: all 0.2s ease;
          cursor: pointer;
        }
        
        .friend-item:hover {
          background: rgba(255, 255, 255, 0.08);
        }
        
        .friend-item.selected {
          background: rgba(250, 255, 14, 0.1);
          border-color: rgba(250, 255, 14, 0.3);
        }
        
        .nav-item {
          transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
        }
        
        .nav-item:hover {
          transform: translateY(-2px);
        }
      `}</style>

      {/* Background Elements */}
      <div style={{
        position: 'absolute',
        top: '10%',
        left: '50%',
        transform: 'translateX(-50%)',
        width: '500px',
        height: '500px',
        background: 'radial-gradient(circle, rgba(125, 103, 254, 0.15) 0%, transparent 60%)',
        borderRadius: '50%',
        filter: 'blur(80px)',
        animation: 'pulse 8s ease-in-out infinite',
      }} />

      {/* Ripple effect during alignment */}
      {isAligning && (
        <>
          <div style={{
            position: 'absolute',
            top: '30%',
            left: '50%',
            transform: 'translate(-50%, -50%)',
            width: '200px',
            height: '200px',
            border: '2px solid rgba(250, 255, 14, 0.3)',
            borderRadius: '50%',
            animation: 'ripple 2s ease-out infinite',
          }} />
          <div style={{
            position: 'absolute',
            top: '30%',
            left: '50%',
            transform: 'translate(-50%, -50%)',
            width: '200px',
            height: '200px',
            border: '2px solid rgba(255, 89, 208, 0.3)',
            borderRadius: '50%',
            animation: 'ripple 2s ease-out infinite 0.5s',
          }} />
        </>
      )}

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
            <svg width="18" height="12" viewBox="0 0 18 12" fill="white"><path d="M1 4C1 3.45 1.45 3 2 3H3C3.55 3 4 3.45 4 4V11C4 11.55 3.55 12 3 12H2C1.45 12 1 11.55 1 11V4Z" fillOpacity="0.4"/><path d="M5 3C5 2.45 5.45 2 6 2H7C7.55 2 8 2.45 8 3V11C8 11.55 7.55 12 7 12H6C5.45 12 5 11.55 5 11V3Z" fillOpacity="0.6"/><path d="M9 1C9 0.45 9.45 0 10 0H11C11.55 0 12 0.45 12 1V11C12 11.55 11.55 12 11 12H10C9.45 12 9 11.55 9 11V1Z"/><path d="M13 2C13 1.45 13.45 1 14 1H15C15.55 1 16 1.45 16 2V11C16 11.55 15.55 12 15 12H14C13.45 12 13 11.55 13 11V2Z"/></svg>
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
          padding: '16px 0 24px',
        }}>
          <button style={{
            background: 'rgba(255, 255, 255, 0.05)',
            border: 'none',
            borderRadius: '12px',
            padding: '10px',
            cursor: 'pointer',
          }}>
            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="white" strokeWidth="2">
              <path d="M19 12H5M12 19l-7-7 7-7"/>
            </svg>
          </button>
          
          <h1 style={{ fontSize: '20px', fontWeight: 700, margin: 0 }}>Align</h1>
          
          <button style={{
            background: 'rgba(255, 255, 255, 0.05)',
            border: 'none',
            borderRadius: '12px',
            padding: '10px',
            cursor: 'pointer',
          }}>
            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="white" strokeWidth="2">
              <circle cx="12" cy="12" r="1"/><circle cx="12" cy="5" r="1"/><circle cx="12" cy="19" r="1"/>
            </svg>
          </button>
        </div>

        {/* Alignment Visualization */}
        <div style={{
          display: 'flex',
          justifyContent: 'center',
          alignItems: 'center',
          gap: '20px',
          marginBottom: '32px',
          minHeight: '200px',
        }}>
          {/* Your Sound Orb */}
          <div style={{ textAlign: 'center' }}>
            <div 
              className={`orb ${isAligning ? 'aligning' : ''}`}
              style={{
                background: 'linear-gradient(135deg, #FF59D0 0%, #7D67FE 50%, #00D4AA 100%)',
                margin: '0 auto 12px',
              }}
            >
              <div className="orb-ring" style={{ inset: '-20px' }} />
              <div className="orb-ring" style={{ inset: '-35px', animationDuration: '30s', animationDirection: 'reverse' }} />
              <div className="orb-inner">
                <div style={{ display: 'flex', gap: '2px', alignItems: 'center' }}>
                  {[0.4, 0.7, 1, 0.8, 0.5, 0.9, 0.6].map((h, i) => (
                    <div key={i} style={{
                      width: '4px',
                      height: `${h * 35}px`,
                      background: 'rgba(255,255,255,0.85)',
                      borderRadius: '2px',
                      animation: `waveform ${0.4 + i * 0.1}s ease-in-out infinite`,
                      animationDelay: `${i * 0.05}s`,
                    }} />
                  ))}
                </div>
              </div>
            </div>
            <p style={{
              fontSize: '11px',
              color: 'rgba(255,255,255,0.5)',
              textTransform: 'uppercase',
              letterSpacing: '2px',
              margin: '0 0 4px 0',
            }}>Your Sound</p>
          </div>

          {/* Connection Indicator */}
          <div style={{
            display: 'flex',
            flexDirection: 'column',
            alignItems: 'center',
            gap: '8px',
          }}>
            {resonanceScore > 0 ? (
              <div style={{
                width: '60px',
                height: '60px',
                borderRadius: '50%',
                background: `conic-gradient(#FAFF0E ${resonanceScore}%, rgba(255,255,255,0.1) ${resonanceScore}%)`,
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
              }}>
                <div style={{
                  width: '48px',
                  height: '48px',
                  borderRadius: '50%',
                  background: '#0D0D15',
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                  fontSize: '14px',
                  fontWeight: 800,
                  color: '#FAFF0E',
                }}>{resonanceScore}%</div>
              </div>
            ) : (
              <div style={{
                width: '80px',
                height: '4px',
                background: 'rgba(255,255,255,0.1)',
                borderRadius: '2px',
                overflow: 'hidden',
              }}>
                <div style={{
                  width: `${alignmentProgress}%`,
                  height: '100%',
                  background: 'linear-gradient(90deg, #FF59D0, #FAFF0E)',
                  borderRadius: '2px',
                  transition: 'width 0.1s ease',
                }} />
              </div>
            )}
          </div>

          {/* Target Sound Orb */}
          <div style={{ textAlign: 'center' }}>
            <div 
              className={`orb ${isAligning ? 'aligning-target' : ''}`}
              style={{
                background: `linear-gradient(135deg, ${targetOrb.color1} 0%, ${targetOrb.color2} 50%, ${targetOrb.color3} 100%)`,
                margin: '0 auto 12px',
                animationDelay: '0.5s',
              }}
            >
              <div className="orb-ring" style={{ inset: '-20px', animationDirection: 'reverse' }} />
              <div className="orb-ring" style={{ inset: '-35px', animationDuration: '25s' }} />
              <div className="orb-inner">
                <div style={{ display: 'flex', gap: '2px', alignItems: 'center' }}>
                  {[0.6, 0.9, 0.5, 1, 0.7, 0.8, 0.4].map((h, i) => (
                    <div key={i} style={{
                      width: '4px',
                      height: `${h * 35}px`,
                      background: 'rgba(255,255,255,0.85)',
                      borderRadius: '2px',
                      animation: `waveform ${0.5 + i * 0.1}s ease-in-out infinite`,
                      animationDelay: `${i * 0.07}s`,
                    }} />
                  ))}
                </div>
              </div>
            </div>
            <p style={{
              fontSize: '11px',
              color: 'rgba(255,255,255,0.5)',
              textTransform: 'uppercase',
              letterSpacing: '2px',
              margin: '0 0 4px 0',
            }}>{targetOrb.label}</p>
          </div>
        </div>

        {/* Resonance Result */}
        {resonanceScore > 0 && (
          <div className="glass-card" style={{
            padding: '20px',
            marginBottom: '24px',
            textAlign: 'center',
          }}>
            <p style={{
              fontSize: '14px',
              color: 'rgba(255,255,255,0.6)',
              margin: '0 0 8px 0',
            }}>Your frequencies are</p>
            <h2 style={{
              fontSize: '28px',
              fontWeight: 800,
              background: 'linear-gradient(135deg, #FAFF0E 0%, #FF59D0 100%)',
              WebkitBackgroundClip: 'text',
              WebkitTextFillColor: 'transparent',
              margin: '0 0 16px 0',
            }}>{resonanceScore}% Aligned</h2>
            
            <div style={{ display: 'flex', gap: '12px' }}>
              <button style={{
                flex: 1,
                background: 'rgba(255, 255, 255, 0.1)',
                border: '1px solid rgba(255, 255, 255, 0.2)',
                borderRadius: '12px',
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
              }}>
                <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                  <polygon points="5 3 19 12 5 21 5 3"/>
                </svg>
                Play Blend
              </button>
              <button style={{
                flex: 1,
                background: 'linear-gradient(135deg, #FAFF0E 0%, #E5EB0D 100%)',
                border: 'none',
                borderRadius: '12px',
                padding: '14px',
                color: '#0A0A0F',
                fontFamily: "'Syne', sans-serif",
                fontWeight: 600,
                fontSize: '13px',
                cursor: 'pointer',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                gap: '8px',
              }}>
                <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                  <path d="M19 21H5a2 2 0 01-2-2V5a2 2 0 012-2h11l5 5v11a2 2 0 01-2 2z"/>
                  <polyline points="17,21 17,13 7,13 7,21"/>
                  <polyline points="7,3 7,8 15,8"/>
                </svg>
                Save Moment
              </button>
            </div>
          </div>
        )}

        {/* Target Selection Tabs */}
        <div className="glass-card" style={{
          padding: '6px',
          marginBottom: '16px',
          display: 'flex',
          gap: '4px',
        }}>
          <button 
            className={`tab-button ${alignTarget === 'today' ? 'active' : ''}`}
            onClick={() => { setAlignTarget('today'); resetAlignment(); }}
          >
            Today
          </button>
          <button 
            className={`tab-button ${alignTarget === 'friend' ? 'active' : ''}`}
            onClick={() => { setAlignTarget('friend'); resetAlignment(); }}
          >
            Friend
          </button>
          <button 
            className={`tab-button ${alignTarget === 'transit' ? 'active' : ''}`}
            onClick={() => { setAlignTarget('transit'); resetAlignment(); }}
          >
            Transit
          </button>
        </div>

        {/* Target Selection Content */}
        <div style={{ marginBottom: '24px' }}>
          {alignTarget === 'today' && (
            <div className="glass-card" style={{ padding: '20px' }}>
              <div style={{ display: 'flex', alignItems: 'center', gap: '16px' }}>
                <div style={{
                  width: '56px',
                  height: '56px',
                  borderRadius: '50%',
                  background: 'linear-gradient(135deg, #FAFF0E 0%, #FF59D0 100%)',
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                }}>
                  <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="#0A0A0F" strokeWidth="2">
                    <circle cx="12" cy="12" r="5"/>
                    <line x1="12" y1="1" x2="12" y2="3"/>
                    <line x1="12" y1="21" x2="12" y2="23"/>
                    <line x1="4.22" y1="4.22" x2="5.64" y2="5.64"/>
                    <line x1="18.36" y1="18.36" x2="19.78" y2="19.78"/>
                    <line x1="1" y1="12" x2="3" y2="12"/>
                    <line x1="21" y1="12" x2="23" y2="12"/>
                    <line x1="4.22" y1="19.78" x2="5.64" y2="18.36"/>
                    <line x1="18.36" y1="5.64" x2="19.78" y2="4.22"/>
                  </svg>
                </div>
                <div style={{ flex: 1 }}>
                  <h3 style={{ fontSize: '16px', fontWeight: 700, margin: '0 0 4px 0' }}>Today's Cosmic Sound</h3>
                  <p style={{ fontSize: '13px', color: 'rgba(255,255,255,0.5)', margin: 0 }}>December 12, 2025 • Scorpio Season</p>
                </div>
              </div>
              <p style={{
                fontSize: '13px',
                color: 'rgba(255,255,255,0.6)',
                lineHeight: '1.6',
                margin: '16px 0 0 0',
                fontFamily: "'Space Grotesk', sans-serif",
              }}>
                The universe hums at 432Hz today, carrying transformative Plutonian energy. Align to release what no longer serves you.
              </p>
            </div>
          )}

          {alignTarget === 'friend' && (
            <div style={{ display: 'flex', flexDirection: 'column', gap: '8px' }}>
              {friends.map((friend) => (
                <div 
                  key={friend.id}
                  className={`glass-card friend-item ${selectedFriend?.id === friend.id ? 'selected' : ''}`}
                  style={{
                    padding: '16px',
                    display: 'flex',
                    alignItems: 'center',
                    gap: '14px',
                    border: selectedFriend?.id === friend.id ? '1px solid rgba(250, 255, 14, 0.3)' : '1px solid rgba(255, 255, 255, 0.08)',
                  }}
                  onClick={() => { setSelectedFriend(friend); resetAlignment(); }}
                >
                  <div style={{
                    width: '48px',
                    height: '48px',
                    borderRadius: '50%',
                    background: `linear-gradient(135deg, ${friend.color1} 0%, ${friend.color2} 100%)`,
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'center',
                    fontSize: '18px',
                    fontWeight: 700,
                  }}>{friend.name[0]}</div>
                  <div style={{ flex: 1 }}>
                    <h4 style={{ fontSize: '15px', fontWeight: 600, margin: '0 0 2px 0' }}>{friend.name}</h4>
                    <p style={{ fontSize: '12px', color: 'rgba(255,255,255,0.5)', margin: 0 }}>
                      {friend.compatibility}% compatible
                    </p>
                  </div>
                  <div style={{
                    width: '36px',
                    height: '36px',
                    borderRadius: '50%',
                    background: selectedFriend?.id === friend.id ? '#FAFF0E' : 'rgba(255, 255, 255, 0.1)',
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'center',
                  }}>
                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke={selectedFriend?.id === friend.id ? '#0A0A0F' : 'white'} strokeWidth="2">
                      <polyline points="20 6 9 17 4 12"/>
                    </svg>
                  </div>
                </div>
              ))}
            </div>
          )}

          {alignTarget === 'transit' && (
            <div style={{ display: 'flex', flexDirection: 'column', gap: '8px' }}>
              {upcomingTransits.map((transit) => (
                <div key={transit.id} className="glass-card" style={{
                  padding: '16px',
                  display: 'flex',
                  alignItems: 'center',
                  gap: '14px',
                  cursor: 'pointer',
                }}>
                  <div style={{
                    width: '48px',
                    height: '48px',
                    borderRadius: '12px',
                    background: 'linear-gradient(135deg, #7D67FE 0%, #FF59D0 100%)',
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'center',
                  }}>
                    <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="white" strokeWidth="2">
                      <circle cx="12" cy="12" r="10"/>
                      <path d="M12 6v6l4 2"/>
                    </svg>
                  </div>
                  <div style={{ flex: 1 }}>
                    <h4 style={{ fontSize: '14px', fontWeight: 600, margin: '0 0 2px 0' }}>{transit.name}</h4>
                    <p style={{ fontSize: '12px', color: 'rgba(255,255,255,0.5)', margin: 0 }}>{transit.date} • {transit.energy}</p>
                  </div>
                  <span style={{
                    fontSize: '11px',
                    color: '#7D67FE',
                    background: 'rgba(125, 103, 254, 0.15)',
                    padding: '4px 10px',
                    borderRadius: '20px',
                  }}>Preview</span>
                </div>
              ))}
            </div>
          )}
        </div>

        {/* Align Button */}
        <button 
          onClick={startAlignment}
          disabled={isAligning || (alignTarget === 'friend' && !selectedFriend)}
          style={{
            width: '100%',
            background: isAligning 
              ? 'rgba(255, 255, 255, 0.1)' 
              : 'linear-gradient(135deg, #7D67FE 0%, #FF59D0 100%)',
            border: 'none',
            borderRadius: '16px',
            padding: '20px',
            fontSize: '16px',
            fontWeight: 700,
            fontFamily: "'Syne', sans-serif",
            color: '#FFFFFF',
            cursor: isAligning || (alignTarget === 'friend' && !selectedFriend) ? 'not-allowed' : 'pointer',
            opacity: (alignTarget === 'friend' && !selectedFriend) ? 0.5 : 1,
            marginBottom: '120px',
            boxShadow: isAligning ? 'none' : '0 8px 32px rgba(125, 103, 254, 0.3)',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            gap: '12px',
          }}
        >
          {isAligning ? (
            <>
              <div style={{
                width: '20px',
                height: '20px',
                border: '2px solid rgba(255,255,255,0.3)',
                borderTopColor: 'white',
                borderRadius: '50%',
                animation: 'rotateRing 1s linear infinite',
              }} />
              Aligning Frequencies...
            </>
          ) : resonanceScore > 0 ? (
            <>
              <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                <path d="M23 4v6h-6M1 20v-6h6"/>
                <path d="M3.51 9a9 9 0 0114.85-3.36L23 10M1 14l4.64 4.36A9 9 0 0020.49 15"/>
              </svg>
              Align Again
            </>
          ) : (
            <>
              <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                <circle cx="12" cy="12" r="10"/>
                <path d="M12 6v6l4 2"/>
              </svg>
              Begin Alignment
            </>
          )}
        </button>

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
              { id: 'align', icon: 'M12 2L2 7L12 12L22 7L12 2ZM2 17L12 22L22 17M2 12L12 17L22 12', label: 'Align' },
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

export default Align;
