import React, { useState } from 'react';

const Home = () => {
  const [activeTab, setActiveTab] = useState('home');
  
  const todaysReading = {
    sign: "Scorpio",
    date: "December 12, 2025",
    energy: "Transformative",
    mood: "Deep House → Ambient",
    bpm: "118-122",
    vibe: "The moon's opposition to Pluto invites you to shed old patterns. Your sonic medicine today is hypnotic, pulsing rhythms that mirror your internal metamorphosis."
  };

  const alignedFriends = [
    { name: "Maya", color1: "#FF59D0", color2: "#7D67FE" },
    { name: "Jordan", color1: "#FAFF0E", color2: "#FF59D0" },
    { name: "Alex", color1: "#7D67FE", color2: "#00D4AA" },
  ];

  const playlist = [
    { title: "Midnight Protocol", artist: "Orbital Dreams", duration: "6:42", energy: 78 },
    { title: "Plutonian Depths", artist: "Modular Witch", duration: "5:18", energy: 85 },
    { title: "Dissolve", artist: "Kiasmos", duration: "7:03", energy: 62 },
  ];

  const alignmentScore = 78;

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
          50% { transform: scaleY(1.3); }
        }
        
        @keyframes connectionPulse {
          0%, 100% { opacity: 0.3; }
          50% { opacity: 0.8; }
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
          width: 100px;
          height: 100px;
          border-radius: 50%;
          animation: float 6s ease-in-out infinite;
        }
        
        .orb::before {
          content: '';
          position: absolute;
          inset: -10px;
          border-radius: 50%;
          background: inherit;
          filter: blur(20px);
          opacity: 0.5;
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
        
        .cta-button {
          flex: 1;
          border: none;
          border-radius: 16px;
          padding: 18px 20px;
          font-size: 14px;
          font-weight: 700;
          font-family: 'Syne', sans-serif;
          cursor: pointer;
          display: flex;
          align-items: center;
          justify-content: center;
          gap: 10px;
          transition: all 0.3s ease;
        }
        
        .cta-button:hover {
          transform: translateY(-2px);
        }
        
        .playlist-item {
          transition: all 0.2s ease;
        }
        
        .playlist-item:hover {
          background: rgba(255, 255, 255, 0.05);
          transform: translateX(4px);
        }
        
        .nav-item {
          transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
        }
        
        .nav-item:hover {
          transform: translateY(-2px);
        }
        
        .energy-bar {
          background: linear-gradient(90deg, #FF59D0, #FAFF0E);
          border-radius: 4px;
          height: 4px;
        }
      `}</style>

      {/* Cosmic Background Elements */}
      <div style={{
        position: 'absolute',
        top: '-20%',
        right: '-10%',
        width: '600px',
        height: '600px',
        background: 'radial-gradient(circle, rgba(255, 89, 208, 0.12) 0%, rgba(125, 103, 254, 0.06) 40%, transparent 70%)',
        borderRadius: '50%',
        filter: 'blur(60px)',
        animation: 'pulse 8s ease-in-out infinite',
      }} />
      
      <div style={{
        position: 'absolute',
        bottom: '20%',
        left: '-15%',
        width: '500px',
        height: '500px',
        background: 'radial-gradient(circle, rgba(250, 255, 14, 0.08) 0%, rgba(255, 89, 208, 0.04) 50%, transparent 70%)',
        borderRadius: '50%',
        filter: 'blur(80px)',
        animation: 'pulse 10s ease-in-out infinite 2s',
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
            <svg width="18" height="12" viewBox="0 0 18 12" fill="white">
              <path d="M1 4C1 3.45 1.45 3 2 3H3C3.55 3 4 3.45 4 4V11C4 11.55 3.55 12 3 12H2C1.45 12 1 11.55 1 11V4Z" fillOpacity="0.4"/>
              <path d="M5 3C5 2.45 5.45 2 6 2H7C7.55 2 8 2.45 8 3V11C8 11.55 7.55 12 7 12H6C5.45 12 5 11.55 5 11V3Z" fillOpacity="0.6"/>
              <path d="M9 1C9 0.45 9.45 0 10 0H11C11.55 0 12 0.45 12 1V11C12 11.55 11.55 12 11 12H10C9.45 12 9 11.55 9 11V1Z"/>
              <path d="M13 2C13 1.45 13.45 1 14 1H15C15.55 1 16 1.45 16 2V11C16 11.55 15.55 12 15 12H14C13.45 12 13 11.55 13 11V2Z"/>
            </svg>
            <svg width="17" height="12" viewBox="0 0 17 12" fill="white">
              <path d="M8.5 2.5C10.5 2.5 12.3 3.3 13.6 4.6L15.1 3.1C13.4 1.4 11.1 0.4 8.5 0.4C5.9 0.4 3.6 1.4 1.9 3.1L3.4 4.6C4.7 3.3 6.5 2.5 8.5 2.5Z"/>
              <path d="M8.5 5.5C9.7 5.5 10.8 6 11.6 6.8L13.1 5.3C11.9 4.1 10.3 3.4 8.5 3.4C6.7 3.4 5.1 4.1 3.9 5.3L5.4 6.8C6.2 6 7.3 5.5 8.5 5.5Z"/>
              <circle cx="8.5" cy="10" r="2"/>
            </svg>
            <div style={{
              width: '28px',
              height: '13px',
              border: '1.5px solid white',
              borderRadius: '4px',
              padding: '2px',
            }}>
              <div style={{
                width: '80%',
                height: '100%',
                background: '#FAFF0E',
                borderRadius: '2px',
              }} />
            </div>
          </div>
        </div>

        {/* Header */}
        <div style={{
          display: 'flex',
          justifyContent: 'space-between',
          alignItems: 'center',
          padding: '16px 0',
        }}>
          <div style={{ width: '40px', height: '40px', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
            <svg width="24" height="18" viewBox="0 0 24 18" fill="none">
              <path d="M0 2H24M0 9H24M0 16H24" stroke="white" strokeWidth="2" strokeLinecap="round"/>
            </svg>
          </div>
          
          <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
            <div style={{ width: '36px', height: '36px', position: 'relative' }}>
              <div style={{
                width: '100%',
                height: '100%',
                border: '2px solid #FAFF0E',
                borderRadius: '50%',
                position: 'relative',
              }}>
                <div style={{
                  position: 'absolute',
                  top: '50%',
                  left: '50%',
                  transform: 'translate(-50%, -50%) rotate(-20deg)',
                  width: '120%',
                  height: '8px',
                  border: '2px solid #FF59D0',
                  borderRadius: '50%',
                }} />
              </div>
            </div>
            <span style={{ fontWeight: 800, fontSize: '18px', letterSpacing: '-0.5px' }}>ASTRO.FM</span>
          </div>
          
          <div style={{ width: '40px', height: '40px', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
            <svg width="24" height="24" viewBox="0 0 24 24" fill="none">
              <path d="M18 8C18 6.4 17.4 4.9 16.2 3.8C15.1 2.6 13.6 2 12 2C10.4 2 8.9 2.6 7.8 3.8C6.6 4.9 6 6.4 6 8C6 15 3 17 3 17H21C21 17 18 15 18 8Z" stroke="white" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/>
              <circle cx="12" cy="21" r="2" fill="#FF59D0"/>
            </svg>
          </div>
        </div>

        {/* Sound Orbs Section */}
        <div className="glass-card" style={{
          padding: '32px 24px',
          marginBottom: '20px',
          position: 'relative',
          overflow: 'hidden',
        }}>
          {/* Background glow */}
          <div style={{
            position: 'absolute',
            top: '50%',
            left: '50%',
            transform: 'translate(-50%, -50%)',
            width: '300px',
            height: '300px',
            background: 'radial-gradient(circle, rgba(125, 103, 254, 0.1) 0%, transparent 70%)',
            borderRadius: '50%',
            filter: 'blur(40px)',
          }} />

          <div style={{
            display: 'flex',
            justifyContent: 'space-around',
            alignItems: 'center',
            position: 'relative',
            zIndex: 1,
            marginBottom: '24px',
          }}>
            {/* Your Sound Orb */}
            <div style={{ textAlign: 'center' }}>
              <div className="orb" style={{
                background: 'linear-gradient(135deg, #FF59D0 0%, #7D67FE 50%, #00D4AA 100%)',
                margin: '0 auto 12px',
              }}>
                <div className="orb-inner">
                  {/* Waveform inside orb */}
                  <div style={{ display: 'flex', gap: '2px', alignItems: 'center' }}>
                    {[0.4, 0.7, 1, 0.8, 0.5, 0.9, 0.6, 0.7, 0.4].map((h, i) => (
                      <div key={i} style={{
                        width: '3px',
                        height: `${h * 30}px`,
                        background: 'rgba(255,255,255,0.8)',
                        borderRadius: '2px',
                        animation: `waveform ${0.5 + i * 0.1}s ease-in-out infinite`,
                        animationDelay: `${i * 0.05}s`,
                      }} />
                    ))}
                  </div>
                </div>
              </div>
              <p style={{
                fontSize: '12px',
                color: 'rgba(255,255,255,0.5)',
                textTransform: 'uppercase',
                letterSpacing: '2px',
                margin: '0 0 4px 0',
                fontFamily: "'Space Grotesk', sans-serif",
              }}>Your Sound</p>
              <p style={{
                fontSize: '14px',
                fontWeight: 600,
                margin: 0,
                color: '#FF59D0',
              }}>Unique to You</p>
            </div>

            {/* Connection Line */}
            <div style={{
              display: 'flex',
              flexDirection: 'column',
              alignItems: 'center',
              gap: '8px',
            }}>
              <div style={{
                width: '60px',
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
                  animation: 'connectionPulse 2s ease-in-out infinite',
                }} />
              </div>
            </div>

            {/* Today's Sound Orb */}
            <div style={{ textAlign: 'center' }}>
              <div className="orb" style={{
                background: 'linear-gradient(135deg, #FAFF0E 0%, #FF59D0 50%, #7D67FE 100%)',
                margin: '0 auto 12px',
                animationDelay: '1s',
              }}>
                <div className="orb-inner">
                  <div style={{ display: 'flex', gap: '2px', alignItems: 'center' }}>
                    {[0.6, 0.9, 0.5, 1, 0.7, 0.8, 0.4, 0.9, 0.6].map((h, i) => (
                      <div key={i} style={{
                        width: '3px',
                        height: `${h * 30}px`,
                        background: 'rgba(255,255,255,0.8)',
                        borderRadius: '2px',
                        animation: `waveform ${0.6 + i * 0.1}s ease-in-out infinite`,
                        animationDelay: `${i * 0.07}s`,
                      }} />
                    ))}
                  </div>
                </div>
              </div>
              <p style={{
                fontSize: '12px',
                color: 'rgba(255,255,255,0.5)',
                textTransform: 'uppercase',
                letterSpacing: '2px',
                margin: '0 0 4px 0',
                fontFamily: "'Space Grotesk', sans-serif",
              }}>Today's Sound</p>
              <p style={{
                fontSize: '14px',
                fontWeight: 600,
                margin: 0,
                color: '#FAFF0E',
              }}>Cosmic Frequency</p>
            </div>
          </div>

          {/* Alignment Score */}
          <div style={{
            display: 'flex',
            justifyContent: 'center',
            marginBottom: '20px',
          }}>
            <div style={{
              background: 'rgba(255, 255, 255, 0.05)',
              border: '1px solid rgba(255, 255, 255, 0.1)',
              borderRadius: '100px',
              padding: '12px 32px',
              display: 'flex',
              alignItems: 'center',
              gap: '12px',
            }}>
              <div style={{
                width: '40px',
                height: '40px',
                borderRadius: '50%',
                background: `conic-gradient(#FAFF0E ${alignmentScore}%, rgba(255,255,255,0.1) ${alignmentScore}%)`,
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
              }}>
                <div style={{
                  width: '32px',
                  height: '32px',
                  borderRadius: '50%',
                  background: '#0D0D15',
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                  fontSize: '11px',
                  fontWeight: 700,
                  color: '#FAFF0E',
                }}>{alignmentScore}%</div>
              </div>
              <div>
                <p style={{
                  fontSize: '14px',
                  fontWeight: 600,
                  margin: 0,
                }}>Aligned Today</p>
                <p style={{
                  fontSize: '11px',
                  color: 'rgba(255,255,255,0.5)',
                  margin: 0,
                  fontFamily: "'Space Grotesk', sans-serif",
                }}>High resonance day</p>
              </div>
            </div>
          </div>

          {/* Friends Aligned */}
          <div style={{
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            gap: '8px',
          }}>
            <span style={{
              fontSize: '12px',
              color: 'rgba(255,255,255,0.5)',
              fontFamily: "'Space Grotesk', sans-serif",
            }}>Friends aligned today:</span>
            <div style={{ display: 'flex', marginLeft: '4px' }}>
              {alignedFriends.map((friend, i) => (
                <div key={i} style={{
                  width: '28px',
                  height: '28px',
                  borderRadius: '50%',
                  background: `linear-gradient(135deg, ${friend.color1}, ${friend.color2})`,
                  border: '2px solid #0D0D15',
                  marginLeft: i > 0 ? '-8px' : 0,
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                  fontSize: '10px',
                  fontWeight: 700,
                }}>{friend.name[0]}</div>
              ))}
              <div style={{
                width: '28px',
                height: '28px',
                borderRadius: '50%',
                background: 'rgba(255,255,255,0.1)',
                border: '2px solid #0D0D15',
                marginLeft: '-8px',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                fontSize: '10px',
                color: 'rgba(255,255,255,0.6)',
              }}>+5</div>
            </div>
          </div>
        </div>

        {/* Dual CTA Buttons */}
        <div style={{
          display: 'flex',
          gap: '12px',
          marginBottom: '24px',
        }}>
          <button className="cta-button" style={{
            background: 'linear-gradient(135deg, #7D67FE 0%, #FF59D0 100%)',
            color: '#FFFFFF',
            boxShadow: '0 8px 32px rgba(125, 103, 254, 0.3)',
          }}>
            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
              <circle cx="12" cy="12" r="10"/>
              <path d="M12 6v6l4 2"/>
            </svg>
            Align Now
          </button>
          
          <button className="cta-button" style={{
            background: 'linear-gradient(135deg, #FAFF0E 0%, #E5EB0D 100%)',
            color: '#0A0A0F',
            boxShadow: '0 8px 32px rgba(250, 255, 14, 0.25)',
          }}>
            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
              <path d="M9 18V5l12-2v13M9 18c0 1.66-1.34 3-3 3s-3-1.34-3-3 1.34-3 3-3 3 1.34 3 3zM21 16c0 1.66-1.34 3-3 3s-3-1.34-3-3 1.34-3 3-3 3 1.34 3 3z"/>
            </svg>
            Generate Playlist
          </button>
        </div>

        {/* Today's Resonance Card */}
        <div className="glass-card" style={{
          padding: '20px',
          marginBottom: '24px',
          position: 'relative',
          overflow: 'hidden',
        }}>
          <div style={{
            position: 'absolute',
            top: '-30%',
            right: '-20%',
            width: '200px',
            height: '200px',
            background: 'radial-gradient(circle, rgba(255, 89, 208, 0.2) 0%, transparent 70%)',
            borderRadius: '50%',
            filter: 'blur(30px)',
          }} />
          
          <div style={{ position: 'relative', zIndex: 1 }}>
            <div style={{
              display: 'flex',
              justifyContent: 'space-between',
              alignItems: 'flex-start',
              marginBottom: '12px',
            }}>
              <div>
                <p style={{
                  fontSize: '11px',
                  color: 'rgba(255, 255, 255, 0.5)',
                  fontFamily: "'Space Grotesk', sans-serif",
                  textTransform: 'uppercase',
                  letterSpacing: '2px',
                  marginBottom: '4px',
                }}>Today's Resonance</p>
                <h2 style={{
                  fontSize: '24px',
                  fontWeight: 800,
                  background: 'linear-gradient(135deg, #FAFF0E 0%, #FF59D0 100%)',
                  WebkitBackgroundClip: 'text',
                  WebkitTextFillColor: 'transparent',
                  backgroundClip: 'text',
                  margin: 0,
                }}>{todaysReading.sign}</h2>
              </div>
              <div style={{
                background: 'rgba(250, 255, 14, 0.15)',
                border: '1px solid rgba(250, 255, 14, 0.3)',
                borderRadius: '20px',
                padding: '4px 12px',
                fontSize: '11px',
                color: '#FAFF0E',
                fontWeight: 600,
              }}>{todaysReading.energy}</div>
            </div>
            
            <div style={{ display: 'flex', gap: '12px', marginBottom: '12px' }}>
              <div style={{
                flex: 1,
                background: 'rgba(255, 255, 255, 0.05)',
                borderRadius: '10px',
                padding: '10px',
              }}>
                <p style={{ fontSize: '10px', color: 'rgba(255,255,255,0.4)', margin: '0 0 2px 0', textTransform: 'uppercase', letterSpacing: '1px' }}>Mood</p>
                <p style={{ fontSize: '13px', fontWeight: 600, color: '#FF59D0', margin: 0 }}>{todaysReading.mood}</p>
              </div>
              <div style={{
                flex: 1,
                background: 'rgba(255, 255, 255, 0.05)',
                borderRadius: '10px',
                padding: '10px',
              }}>
                <p style={{ fontSize: '10px', color: 'rgba(255,255,255,0.4)', margin: '0 0 2px 0', textTransform: 'uppercase', letterSpacing: '1px' }}>BPM</p>
                <p style={{ fontSize: '13px', fontWeight: 600, color: '#7D67FE', margin: 0 }}>{todaysReading.bpm}</p>
              </div>
            </div>
            
            <p style={{
              fontSize: '13px',
              lineHeight: '1.6',
              color: 'rgba(255, 255, 255, 0.7)',
              fontFamily: "'Space Grotesk', sans-serif",
              margin: 0,
            }}>{todaysReading.vibe}</p>
          </div>
        </div>

        {/* Cosmic Queue */}
        <div style={{ marginBottom: '120px' }}>
          <div style={{
            display: 'flex',
            justifyContent: 'space-between',
            alignItems: 'center',
            marginBottom: '12px',
          }}>
            <h3 style={{ fontSize: '16px', fontWeight: 700, margin: 0 }}>Your Cosmic Queue</h3>
            <span style={{ fontSize: '13px', color: '#FF59D0', fontWeight: 600, cursor: 'pointer' }}>See All</span>
          </div>
          
          <div className="glass-card" style={{ padding: '8px' }}>
            {playlist.map((track, index) => (
              <div key={index} className="playlist-item" style={{
                display: 'flex',
                alignItems: 'center',
                gap: '14px',
                padding: '14px',
                borderRadius: '14px',
                cursor: 'pointer',
              }}>
                <div style={{
                  width: '48px',
                  height: '48px',
                  borderRadius: '10px',
                  background: `linear-gradient(135deg, ${index % 2 === 0 ? '#FF59D0' : '#7D67FE'} 0%, ${index % 2 === 0 ? '#7D67FE' : '#FAFF0E'} 100%)`,
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                  flexShrink: 0,
                }}>
                  <svg width="18" height="18" viewBox="0 0 24 24" fill="white">
                    <polygon points="5,3 19,12 5,21"/>
                  </svg>
                </div>
                
                <div style={{ flex: 1, minWidth: 0 }}>
                  <p style={{ fontSize: '14px', fontWeight: 600, margin: '0 0 3px 0', whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis' }}>{track.title}</p>
                  <p style={{ fontSize: '12px', color: 'rgba(255,255,255,0.5)', margin: '0 0 6px 0', fontFamily: "'Space Grotesk', sans-serif" }}>{track.artist}</p>
                  <div style={{ width: '100%', height: '3px', background: 'rgba(255,255,255,0.1)', borderRadius: '3px', overflow: 'hidden' }}>
                    <div className="energy-bar" style={{ width: `${track.energy}%` }} />
                  </div>
                </div>
                
                <span style={{ fontSize: '12px', color: 'rgba(255,255,255,0.4)', fontFamily: "'Space Grotesk', sans-serif" }}>{track.duration}</span>
              </div>
            ))}
          </div>
        </div>

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

export default Home;
