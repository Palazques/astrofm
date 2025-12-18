import React, { useState } from 'react';

const FriendProfile = () => {
  const [showMenu, setShowMenu] = useState(false);
  const [isPlayingSound, setIsPlayingSound] = useState(false);

  const friend = {
    name: "Maya Chen",
    username: "@mayacelestial",
    avatar: { color1: "#FF59D0", color2: "#7D67FE", color3: "#00D4AA" },
    sun: "Pisces",
    moon: "Cancer",
    rising: "Scorpio",
    dominantFrequency: "432 Hz",
    element: "Water",
    modality: "Mutable",
  };

  const compatibility = {
    score: 87,
    breakdown: [
      { symbol: "☽", label: "Moon Harmony", value: 92, color: "#FF59D0" },
      { symbol: "☿", label: "Communication", value: 78, color: "#FAFF0E" },
      { symbol: "♀", label: "Love Language", value: 91, color: "#7D67FE" },
      { symbol: "♂", label: "Energy Sync", value: 84, color: "#00D4AA" },
    ],
    insight: "Your water signs create deep emotional understanding. Maya's Pisces sun flows naturally with your Cancer moon, fostering intuitive connection.",
    boostTips: {
      activity: "Spend time near water today — a lake, river, or even a long shower together amplifies your connection.",
      playlist: "Ambient Drift Vol. 3",
    },
  };

  const todaysAlignment = {
    sharedEnergy: "Emotional Depth",
    description: "Both of your charts are activated by today's Moon-Neptune trine. Expect heightened intuition and unspoken understanding.",
    yourMood: "Reflective",
    theirMood: "Dreamy",
  };

  const friendHoroscope = {
    sign: "Pisces",
    mood: "Introspective",
    energy: "Flowing → Mystical",
    reading: "The cosmos invites you to dive deep into your subconscious. Creative downloads are available if you slow down enough to receive them.",
  };

  const friendPlaylists = [
    { id: 1, name: "Lunar Waves", trackCount: 24 },
    { id: 2, name: "Deep Focus Flow", trackCount: 18 },
    { id: 3, name: "Midnight Frequencies", trackCount: 31 },
  ];

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
        
        @keyframes rotateRing {
          0% { transform: rotate(0deg); }
          100% { transform: rotate(360deg); }
        }
        
        @keyframes waveform {
          0%, 100% { transform: scaleY(1); }
          50% { transform: scaleY(1.4); }
        }
        
        .glass-card {
          background: rgba(255, 255, 255, 0.03);
          backdrop-filter: blur(20px);
          -webkit-backdrop-filter: blur(20px);
          border: 1px solid rgba(255, 255, 255, 0.08);
          border-radius: 24px;
        }
        
        .profile-orb {
          position: relative;
          width: 100px;
          height: 100px;
          border-radius: 50%;
          animation: float 6s ease-in-out infinite;
        }
        
        .profile-orb::before {
          content: '';
          position: absolute;
          inset: -12px;
          border-radius: 50%;
          background: inherit;
          filter: blur(20px);
          opacity: 0.5;
          animation: orbGlow 4s ease-in-out infinite;
        }
        
        .orb-ring {
          position: absolute;
          border: 1px solid rgba(255, 255, 255, 0.15);
          border-radius: 50%;
          animation: rotateRing 20s linear infinite;
        }
        
        .mini-orb {
          position: relative;
          width: 48px;
          height: 48px;
          border-radius: 50%;
        }
        
        .mini-orb::before {
          content: '';
          position: absolute;
          inset: -6px;
          border-radius: 50%;
          background: inherit;
          filter: blur(10px);
          opacity: 0.4;
        }
        
        .sound-orb {
          position: relative;
          width: 80px;
          height: 80px;
          border-radius: 50%;
          animation: float 5s ease-in-out infinite;
        }
        
        .sound-orb::before {
          content: '';
          position: absolute;
          inset: -10px;
          border-radius: 50%;
          background: inherit;
          filter: blur(15px);
          opacity: 0.5;
        }
        
        .chip {
          transition: all 0.2s ease;
        }
        
        .chip:hover {
          transform: translateY(-2px);
        }
        
        .playlist-item {
          transition: all 0.2s ease;
        }
        
        .playlist-item:hover {
          background: rgba(255, 255, 255, 0.08);
          transform: translateX(4px);
        }
        
        .cta-button {
          transition: all 0.3s ease;
        }
        
        .cta-button:hover {
          transform: translateY(-2px);
        }
        
        .menu-overlay {
          animation: fadeIn 0.2s ease;
        }
        
        @keyframes fadeIn {
          from { opacity: 0; }
          to { opacity: 1; }
        }
        
        .menu-item {
          transition: all 0.2s ease;
        }
        
        .menu-item:hover {
          background: rgba(255, 255, 255, 0.1);
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
        top: '5%',
        left: '50%',
        transform: 'translateX(-50%)',
        width: '500px',
        height: '500px',
        background: `radial-gradient(circle, ${friend.avatar.color1}15 0%, ${friend.avatar.color2}08 40%, transparent 70%)`,
        borderRadius: '50%',
        filter: 'blur(60px)',
        animation: 'pulse 10s ease-in-out infinite',
      }} />

      {/* Overflow Menu Overlay */}
      {showMenu && (
        <div
          className="menu-overlay"
          style={{
            position: 'fixed',
            inset: 0,
            background: 'rgba(0,0,0,0.5)',
            zIndex: 100,
          }}
          onClick={() => setShowMenu(false)}
        >
          <div style={{
            position: 'absolute',
            top: '80px',
            right: '20px',
            background: '#1E1E2E',
            border: '1px solid rgba(255,255,255,0.1)',
            borderRadius: '16px',
            overflow: 'hidden',
            minWidth: '180px',
          }} onClick={(e) => e.stopPropagation()}>
            {['Remove Friend', 'Block', 'Report'].map((item, index) => (
              <div
                key={item}
                className="menu-item"
                style={{
                  padding: '14px 18px',
                  fontSize: '14px',
                  fontWeight: 500,
                  cursor: 'pointer',
                  color: item === 'Report' || item === 'Block' ? '#E84855' : 'white',
                  borderBottom: index < 2 ? '1px solid rgba(255,255,255,0.06)' : 'none',
                }}
              >
                {item}
              </div>
            ))}
          </div>
        </div>
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
            <svg width="18" height="12" viewBox="0 0 18 12" fill="white"><path d="M1 4C1 3.45 1.45 3 2 3H3C3.55 3 4 3.45 4 4V11C4 11.55 3.55 12 3 12H2C1.45 12 1 11.55 1 11V4Z" fillOpacity="0.4" /><path d="M5 3C5 2.45 5.45 2 6 2H7C7.55 2 8 2.45 8 3V11C8 11.55 7.55 12 7 12H6C5.45 12 5 11.55 5 11V3Z" fillOpacity="0.6" /><path d="M9 1C9 0.45 9.45 0 10 0H11C11.55 0 12 0.45 12 1V11C12 11.55 11.55 12 11 12H10C9.45 12 9 11.55 9 11V1Z" /><path d="M13 2C13 1.45 13.45 1 14 1H15C15.55 1 16 1.45 16 2V11C16 11.55 15.55 12 15 12H14C13.45 12 13 11.55 13 11V2Z" /></svg>
            <div style={{ width: '28px', height: '13px', border: '1.5px solid white', borderRadius: '4px', padding: '2px' }}>
              <div style={{ width: '80%', height: '100%', background: '#FAFF0E', borderRadius: '2px' }} />
            </div>
          </div>
        </div>

        {/* ============ 1. HEADER ============ */}
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
              <path d="M19 12H5M12 19l-7-7 7-7" />
            </svg>
          </button>

          <span style={{ fontSize: '14px', color: 'rgba(255,255,255,0.5)', fontFamily: "'Space Grotesk', sans-serif" }}>Friend Profile</span>

          <button
            onClick={() => setShowMenu(true)}
            style={{
              background: 'rgba(255, 255, 255, 0.05)',
              border: 'none',
              borderRadius: '12px',
              padding: '10px',
              cursor: 'pointer',
            }}
          >
            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="white" strokeWidth="2">
              <circle cx="12" cy="12" r="1" /><circle cx="12" cy="5" r="1" /><circle cx="12" cy="19" r="1" />
            </svg>
          </button>
        </div>

        {/* Profile Header */}
        <div style={{ textAlign: 'center', marginBottom: '24px' }}>
          {/* Profile Orb */}
          <div
            className="profile-orb"
            style={{
              background: `linear-gradient(135deg, ${friend.avatar.color1} 0%, ${friend.avatar.color2} 50%, ${friend.avatar.color3} 100%)`,
              margin: '0 auto 16px',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
            }}
          >
            <div className="orb-ring" style={{ inset: '-15px' }} />
            <div className="orb-ring" style={{ inset: '-28px', animationDuration: '30s', animationDirection: 'reverse' }} />
            <span style={{ fontSize: '36px', fontWeight: 800, position: 'relative', zIndex: 1 }}>
              {friend.name.split(' ').map(n => n[0]).join('')}
            </span>
          </div>

          {/* Name & Username */}
          <h1 style={{
            fontSize: '24px',
            fontWeight: 800,
            margin: '0 0 4px 0',
          }}>{friend.name}</h1>
          <p style={{
            fontSize: '14px',
            color: 'rgba(255,255,255,0.5)',
            margin: '0 0 16px 0',
            fontFamily: "'Space Grotesk', sans-serif",
          }}>{friend.username}</p>

          {/* Big Three Tags */}
          <div style={{ display: 'flex', justifyContent: 'center', gap: '10px', flexWrap: 'wrap' }}>
            <div style={{
              background: 'rgba(250, 255, 14, 0.1)',
              border: '1px solid rgba(250, 255, 14, 0.2)',
              borderRadius: '20px',
              padding: '6px 14px',
              display: 'flex',
              alignItems: 'center',
              gap: '6px',
            }}>
              <span style={{ fontSize: '14px' }}>☉</span>
              <span style={{ fontSize: '12px', color: '#FAFF0E', fontWeight: 600 }}>{friend.sun}</span>
            </div>
            <div style={{
              background: 'rgba(255, 89, 208, 0.1)',
              border: '1px solid rgba(255, 89, 208, 0.2)',
              borderRadius: '20px',
              padding: '6px 14px',
              display: 'flex',
              alignItems: 'center',
              gap: '6px',
            }}>
              <span style={{ fontSize: '14px' }}>☽</span>
              <span style={{ fontSize: '12px', color: '#FF59D0', fontWeight: 600 }}>{friend.moon}</span>
            </div>
            <div style={{
              background: 'rgba(125, 103, 254, 0.1)',
              border: '1px solid rgba(125, 103, 254, 0.2)',
              borderRadius: '20px',
              padding: '6px 14px',
              display: 'flex',
              alignItems: 'center',
              gap: '6px',
            }}>
              <span style={{ fontSize: '14px' }}>↑</span>
              <span style={{ fontSize: '12px', color: '#7D67FE', fontWeight: 600 }}>{friend.rising}</span>
            </div>
          </div>
        </div>

        {/* ============ 2. COMPATIBILITY SCORE ============ */}
        <div className="glass-card" style={{ padding: '24px', marginBottom: '16px' }}>
          {/* Score Display */}
          <div style={{ textAlign: 'center', marginBottom: '20px' }}>
            <p style={{
              fontSize: '11px',
              color: 'rgba(255,255,255,0.5)',
              textTransform: 'uppercase',
              letterSpacing: '2px',
              margin: '0 0 8px 0',
            }}>Compatibility</p>
            <div style={{
              fontSize: '56px',
              fontWeight: 800,
              background: 'linear-gradient(135deg, #FAFF0E 0%, #FF59D0 50%, #7D67FE 100%)',
              WebkitBackgroundClip: 'text',
              WebkitTextFillColor: 'transparent',
              lineHeight: 1,
              margin: '0 0 4px 0',
            }}>{compatibility.score}%</div>
          </div>

          {/* Breakdown Chips */}
          <div style={{
            display: 'grid',
            gridTemplateColumns: 'repeat(2, 1fr)',
            gap: '10px',
            marginBottom: '20px',
          }}>
            {compatibility.breakdown.map((item) => (
              <div
                key={item.label}
                className="chip"
                style={{
                  background: `${item.color}10`,
                  border: `1px solid ${item.color}30`,
                  borderRadius: '12px',
                  padding: '12px',
                  display: 'flex',
                  alignItems: 'center',
                  gap: '10px',
                }}
              >
                <span style={{ fontSize: '18px' }}>{item.symbol}</span>
                <div style={{ flex: 1 }}>
                  <p style={{ fontSize: '11px', color: 'rgba(255,255,255,0.5)', margin: '0 0 2px 0' }}>{item.label}</p>
                  <p style={{ fontSize: '14px', fontWeight: 700, color: item.color, margin: 0 }}>{item.value}%</p>
                </div>
              </div>
            ))}
          </div>

          {/* AI Insight */}
          <p style={{
            fontSize: '13px',
            color: 'rgba(255,255,255,0.7)',
            lineHeight: '1.6',
            fontFamily: "'Space Grotesk', sans-serif",
            margin: '0 0 20px 0',
            padding: '16px',
            background: 'rgba(255,255,255,0.03)',
            borderRadius: '12px',
            borderLeft: '3px solid #7D67FE',
          }}>{compatibility.insight}</p>

          {/* Boost Compatibility Section */}
          <div style={{
            background: 'linear-gradient(135deg, rgba(250,255,14,0.1) 0%, rgba(255,89,208,0.1) 100%)',
            border: '1px solid rgba(250,255,14,0.2)',
            borderRadius: '16px',
            padding: '16px',
          }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: '8px', marginBottom: '12px' }}>
              <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#FAFF0E" strokeWidth="2">
                <path d="M13 2L3 14h9l-1 8 10-12h-9l1-8z" />
              </svg>
              <span style={{ fontSize: '13px', fontWeight: 700, color: '#FAFF0E' }}>Boost Your Compatibility</span>
            </div>

            <div style={{ display: 'flex', flexDirection: 'column', gap: '10px' }}>
              <div style={{ display: 'flex', alignItems: 'flex-start', gap: '10px' }}>
                <div style={{
                  width: '28px',
                  height: '28px',
                  borderRadius: '8px',
                  background: 'rgba(255,255,255,0.1)',
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                  flexShrink: 0,
                }}>
                  <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="white" strokeWidth="2">
                    <circle cx="12" cy="12" r="10" />
                    <path d="M12 6v6l4 2" />
                  </svg>
                </div>
                <p style={{ fontSize: '12px', color: 'rgba(255,255,255,0.7)', margin: 0, lineHeight: '1.5', fontFamily: "'Space Grotesk', sans-serif" }}>
                  {compatibility.boostTips.activity}
                </p>
              </div>

              <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
                <div style={{
                  width: '28px',
                  height: '28px',
                  borderRadius: '8px',
                  background: 'rgba(255,255,255,0.1)',
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                  flexShrink: 0,
                }}>
                  <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="white" strokeWidth="2">
                    <path d="M9 18V5l12-2v13" />
                    <circle cx="6" cy="18" r="3" />
                    <circle cx="18" cy="16" r="3" />
                  </svg>
                </div>
                <p style={{ fontSize: '12px', color: 'rgba(255,255,255,0.7)', margin: 0, fontFamily: "'Space Grotesk', sans-serif" }}>
                  Listen together: <span style={{ color: '#FF59D0', fontWeight: 600 }}>{compatibility.boostTips.playlist}</span>
                </p>
              </div>
            </div>
          </div>
        </div>

        {/* ============ 3. TODAY'S ALIGNMENT ============ */}
        <div className="glass-card" style={{ padding: '20px', marginBottom: '16px' }}>
          <p style={{
            fontSize: '11px',
            color: 'rgba(255,255,255,0.5)',
            textTransform: 'uppercase',
            letterSpacing: '2px',
            margin: '0 0 16px 0',
          }}>Today's Alignment</p>

          {/* Dual Orbs */}
          <div style={{
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            gap: '16px',
            marginBottom: '16px',
          }}>
            <div style={{ textAlign: 'center' }}>
              <div
                className="mini-orb"
                style={{
                  background: 'linear-gradient(135deg, #FF59D0 0%, #7D67FE 100%)',
                  margin: '0 auto 8px',
                }}
              />
              <p style={{ fontSize: '10px', color: 'rgba(255,255,255,0.5)', margin: 0 }}>You</p>
              <p style={{ fontSize: '11px', fontWeight: 600, margin: 0 }}>{todaysAlignment.yourMood}</p>
            </div>

            <div style={{
              width: '40px',
              height: '2px',
              background: 'linear-gradient(90deg, #FF59D0, #FAFF0E)',
              position: 'relative',
            }}>
              <div style={{
                position: 'absolute',
                top: '50%',
                left: '50%',
                transform: 'translate(-50%, -50%)',
                width: '8px',
                height: '8px',
                background: '#FAFF0E',
                borderRadius: '50%',
                boxShadow: '0 0 10px #FAFF0E',
              }} />
            </div>

            <div style={{ textAlign: 'center' }}>
              <div
                className="mini-orb"
                style={{
                  background: `linear-gradient(135deg, ${friend.avatar.color1} 0%, ${friend.avatar.color2} 100%)`,
                  margin: '0 auto 8px',
                }}
              />
              <p style={{ fontSize: '10px', color: 'rgba(255,255,255,0.5)', margin: 0 }}>{friend.name.split(' ')[0]}</p>
              <p style={{ fontSize: '11px', fontWeight: 600, margin: 0 }}>{todaysAlignment.theirMood}</p>
            </div>
          </div>

          {/* Shared Energy */}
          <div style={{
            textAlign: 'center',
            background: 'rgba(125, 103, 254, 0.1)',
            borderRadius: '12px',
            padding: '12px',
            marginBottom: '12px',
          }}>
            <p style={{ fontSize: '10px', color: 'rgba(255,255,255,0.5)', margin: '0 0 4px 0', textTransform: 'uppercase', letterSpacing: '1px' }}>Shared Energy</p>
            <p style={{ fontSize: '16px', fontWeight: 700, color: '#7D67FE', margin: 0 }}>{todaysAlignment.sharedEnergy}</p>
          </div>

          <p style={{
            fontSize: '12px',
            color: 'rgba(255,255,255,0.6)',
            lineHeight: '1.5',
            margin: 0,
            fontFamily: "'Space Grotesk', sans-serif",
            textAlign: 'center',
          }}>{todaysAlignment.description}</p>
        </div>

        {/* ============ 4. THEIR HOROSCOPE ============ */}
        <div className="glass-card" style={{ padding: '20px', marginBottom: '16px' }}>
          <div style={{
            display: 'flex',
            justifyContent: 'space-between',
            alignItems: 'flex-start',
            marginBottom: '12px',
          }}>
            <div>
              <p style={{
                fontSize: '11px',
                color: 'rgba(255,255,255,0.5)',
                textTransform: 'uppercase',
                letterSpacing: '2px',
                margin: '0 0 4px 0',
              }}>{friend.name.split(' ')[0]}'s Horoscope</p>
              <h3 style={{
                fontSize: '20px',
                fontWeight: 700,
                margin: 0,
                color: '#FF59D0',
              }}>{friendHoroscope.sign}</h3>
            </div>
            <div style={{ display: 'flex', gap: '8px' }}>
              <div style={{
                background: 'rgba(255, 89, 208, 0.15)',
                borderRadius: '12px',
                padding: '6px 10px',
              }}>
                <span style={{ fontSize: '11px', color: '#FF59D0', fontWeight: 600 }}>{friendHoroscope.mood}</span>
              </div>
            </div>
          </div>

          <div style={{
            background: 'rgba(255,255,255,0.03)',
            borderRadius: '10px',
            padding: '10px 12px',
            marginBottom: '12px',
          }}>
            <p style={{ fontSize: '10px', color: 'rgba(255,255,255,0.4)', margin: '0 0 2px 0', textTransform: 'uppercase', letterSpacing: '1px' }}>Energy</p>
            <p style={{ fontSize: '13px', fontWeight: 600, color: '#FAFF0E', margin: 0 }}>{friendHoroscope.energy}</p>
          </div>

          <p style={{
            fontSize: '13px',
            color: 'rgba(255,255,255,0.7)',
            lineHeight: '1.6',
            margin: 0,
            fontFamily: "'Space Grotesk', sans-serif",
          }}>{friendHoroscope.reading}</p>
        </div>

        {/* ============ 5. THEIR SOUND ============ */}
        <div className="glass-card" style={{ padding: '20px', marginBottom: '16px' }}>
          <p style={{
            fontSize: '11px',
            color: 'rgba(255,255,255,0.5)',
            textTransform: 'uppercase',
            letterSpacing: '2px',
            margin: '0 0 16px 0',
          }}>{friend.name.split(' ')[0]}'s Sound</p>

          <div style={{
            display: 'flex',
            alignItems: 'center',
            gap: '20px',
          }}>
            {/* Sound Orb */}
            <div
              className="sound-orb"
              style={{
                background: `linear-gradient(135deg, ${friend.avatar.color1} 0%, ${friend.avatar.color2} 50%, ${friend.avatar.color3} 100%)`,
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                flexShrink: 0,
              }}
            >
              <div style={{ display: 'flex', gap: '2px', alignItems: 'center' }}>
                {[0.4, 0.7, 1, 0.8, 0.5, 0.9, 0.6].map((h, i) => (
                  <div key={i} style={{
                    width: '3px',
                    height: `${h * 25}px`,
                    background: 'rgba(255,255,255,0.85)',
                    borderRadius: '2px',
                    animation: isPlayingSound ? `waveform ${0.4 + i * 0.1}s ease-in-out infinite` : 'none',
                    animationDelay: `${i * 0.05}s`,
                  }} />
                ))}
              </div>
            </div>

            {/* Sound Info */}
            <div style={{ flex: 1 }}>
              <div style={{ display: 'flex', gap: '8px', marginBottom: '12px', flexWrap: 'wrap' }}>
                <div style={{
                  background: 'rgba(250, 255, 14, 0.1)',
                  border: '1px solid rgba(250, 255, 14, 0.2)',
                  borderRadius: '8px',
                  padding: '4px 10px',
                }}>
                  <span style={{ fontSize: '11px', color: '#FAFF0E', fontWeight: 600 }}>{friend.dominantFrequency}</span>
                </div>
                <div style={{
                  background: 'rgba(125, 103, 254, 0.1)',
                  border: '1px solid rgba(125, 103, 254, 0.2)',
                  borderRadius: '8px',
                  padding: '4px 10px',
                }}>
                  <span style={{ fontSize: '11px', color: '#7D67FE', fontWeight: 600 }}>{friend.element}</span>
                </div>
                <div style={{
                  background: 'rgba(255, 89, 208, 0.1)',
                  border: '1px solid rgba(255, 89, 208, 0.2)',
                  borderRadius: '8px',
                  padding: '4px 10px',
                }}>
                  <span style={{ fontSize: '11px', color: '#FF59D0', fontWeight: 600 }}>{friend.modality}</span>
                </div>
              </div>

              <button
                onClick={() => setIsPlayingSound(!isPlayingSound)}
                style={{
                  background: isPlayingSound ? 'rgba(255,255,255,0.1)' : 'linear-gradient(135deg, #FF59D0 0%, #7D67FE 100%)',
                  border: isPlayingSound ? '1px solid rgba(255,255,255,0.2)' : 'none',
                  borderRadius: '12px',
                  padding: '10px 16px',
                  fontSize: '12px',
                  fontWeight: 600,
                  fontFamily: "'Syne', sans-serif",
                  color: 'white',
                  cursor: 'pointer',
                  display: 'flex',
                  alignItems: 'center',
                  gap: '8px',
                }}
              >
                {isPlayingSound ? (
                  <>
                    <svg width="14" height="14" viewBox="0 0 24 24" fill="currentColor">
                      <rect x="6" y="4" width="4" height="16" rx="1" />
                      <rect x="14" y="4" width="4" height="16" rx="1" />
                    </svg>
                    Pause Sound
                  </>
                ) : (
                  <>
                    <svg width="14" height="14" viewBox="0 0 24 24" fill="currentColor">
                      <polygon points="5 3 19 12 5 21 5 3" />
                    </svg>
                    Listen to {friend.name.split(' ')[0]}'s Sound
                  </>
                )}
              </button>
            </div>
          </div>
        </div>

        {/* ============ 6. THEIR PLAYLISTS ============ */}
        <div style={{ marginBottom: '16px' }}>
          <div style={{
            display: 'flex',
            justifyContent: 'space-between',
            alignItems: 'center',
            marginBottom: '12px',
          }}>
            <p style={{
              fontSize: '11px',
              color: 'rgba(255,255,255,0.5)',
              textTransform: 'uppercase',
              letterSpacing: '2px',
              margin: 0,
            }}>{friend.name.split(' ')[0]}'s Playlists</p>
            <span style={{ fontSize: '12px', color: '#7D67FE', fontWeight: 600, cursor: 'pointer' }}>See All</span>
          </div>

          <div className="glass-card" style={{ padding: '8px' }}>
            {friendPlaylists.map((playlist, index) => (
              <div
                key={playlist.id}
                className="playlist-item"
                style={{
                  display: 'flex',
                  alignItems: 'center',
                  gap: '14px',
                  padding: '14px',
                  borderRadius: '12px',
                  cursor: 'pointer',
                  borderBottom: index < friendPlaylists.length - 1 ? '1px solid rgba(255,255,255,0.06)' : 'none',
                }}
              >
                <div style={{
                  width: '44px',
                  height: '44px',
                  borderRadius: '10px',
                  background: `linear-gradient(135deg, ${friend.avatar.color1}60 0%, ${friend.avatar.color2}60 100%)`,
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                }}>
                  <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="white" strokeWidth="2">
                    <path d="M9 18V5l12-2v13" />
                    <circle cx="6" cy="18" r="3" />
                    <circle cx="18" cy="16" r="3" />
                  </svg>
                </div>
                <div style={{ flex: 1 }}>
                  <p style={{ fontSize: '14px', fontWeight: 600, margin: '0 0 2px 0' }}>{playlist.name}</p>
                  <p style={{ fontSize: '12px', color: 'rgba(255,255,255,0.5)', margin: 0, fontFamily: "'Space Grotesk', sans-serif" }}>{playlist.trackCount} tracks</p>
                </div>
                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="rgba(255,255,255,0.3)" strokeWidth="2">
                  <path d="M9 18l6-6-6-6" />
                </svg>
              </div>
            ))}
          </div>
        </div>

        {/* ============ 7. PRIMARY CTAs ============ */}
        <div style={{
          display: 'flex',
          flexDirection: 'column',
          gap: '12px',
          marginBottom: '40px',
        }}>
          <button
            className="cta-button"
            style={{
              width: '100%',
              background: 'linear-gradient(135deg, #7D67FE 0%, #FF59D0 100%)',
              border: 'none',
              borderRadius: '16px',
              padding: '18px',
              fontSize: '15px',
              fontWeight: 700,
              fontFamily: "'Syne', sans-serif",
              color: 'white',
              cursor: 'pointer',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              gap: '10px',
              boxShadow: '0 8px 32px rgba(125, 103, 254, 0.3)',
            }}
          >
            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
              <circle cx="12" cy="12" r="10" />
              <path d="M12 6v6l4 2" />
            </svg>
            Align with {friend.name.split(' ')[0]}
          </button>

          <button
            className="cta-button"
            style={{
              width: '100%',
              background: 'linear-gradient(135deg, #FAFF0E 0%, #E5EB0D 100%)',
              border: 'none',
              borderRadius: '16px',
              padding: '18px',
              fontSize: '15px',
              fontWeight: 700,
              fontFamily: "'Syne', sans-serif",
              color: '#0A0A0F',
              cursor: 'pointer',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              gap: '10px',
              boxShadow: '0 8px 32px rgba(250, 255, 14, 0.25)',
            }}
          >
            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
              <path d="M9 18V5l12-2v13" />
              <circle cx="6" cy="18" r="3" />
              <circle cx="18" cy="16" r="3" />
            </svg>
            Share Your Day's Playlist
          </button>
        </div>

      </div>
    </div>
  );
};

export default FriendProfile;