import React, { useState } from 'react';

const YourSound = () => {
  const [activeTab, setActiveTab] = useState('sound');
  const [isPlaying, setIsPlaying] = useState(false);

  const soundProfile = {
    name: "Paul",
    sign: "Cancer",
    createdFrom: "July 15, 1990 • 3:42 PM • Los Angeles, CA",
    dominantFrequency: "528 Hz",
    element: "Water",
    modality: "Cardinal",
  };

  const frequencyBreakdown = [
    { planet: "Sun", sign: "Cancer", frequency: "528 Hz", color: "#FAFF0E", description: "Core essence • Nurturing vibration" },
    { planet: "Moon", sign: "Scorpio", frequency: "432 Hz", color: "#FF59D0", description: "Emotional depth • Transformative pulse" },
    { planet: "Rising", sign: "Libra", frequency: "396 Hz", color: "#7D67FE", description: "Outer expression • Harmonic balance" },
    { planet: "Mercury", sign: "Leo", frequency: "741 Hz", color: "#00D4AA", description: "Communication • Creative expression" },
    { planet: "Venus", sign: "Gemini", frequency: "639 Hz", color: "#FF8C42", description: "Love language • Curious connection" },
    { planet: "Mars", sign: "Taurus", frequency: "417 Hz", color: "#E84855", description: "Drive • Steady determination" },
  ];

  const todaysInfluence = {
    transit: "Moon conjunct your natal Pluto",
    effect: "Your sound carries extra intensity today. Deep bass frequencies are amplified.",
    shift: "+12% depth",
  };

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
          50% { transform: translateY(-15px); }
        }
        
        @keyframes pulse {
          0%, 100% { opacity: 0.6; transform: scale(1); }
          50% { opacity: 1; transform: scale(1.05); }
        }
        
        @keyframes orbGlow {
          0%, 100% { filter: blur(30px) brightness(1); }
          50% { filter: blur(40px) brightness(1.3); }
        }
        
        @keyframes waveform {
          0%, 100% { transform: scaleY(1); }
          50% { transform: scaleY(1.5); }
        }
        
        @keyframes rotateRing {
          0% { transform: rotate(0deg); }
          100% { transform: rotate(360deg); }
        }
        
        @keyframes soundWave {
          0% { transform: translate(-50%, -50%) scale(1); opacity: 0.8; }
          100% { transform: translate(-50%, -50%) scale(2.5); opacity: 0; }
        }
        
        .glass-card {
          background: rgba(255, 255, 255, 0.03);
          backdrop-filter: blur(20px);
          -webkit-backdrop-filter: blur(20px);
          border: 1px solid rgba(255, 255, 255, 0.08);
          border-radius: 24px;
        }
        
        .main-orb {
          position: relative;
          width: 180px;
          height: 180px;
          border-radius: 50%;
          animation: float 8s ease-in-out infinite;
        }
        
        .main-orb::before {
          content: '';
          position: absolute;
          inset: -25px;
          border-radius: 50%;
          background: inherit;
          filter: blur(35px);
          opacity: 0.7;
          animation: orbGlow 5s ease-in-out infinite;
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
          border: 1px solid rgba(255, 255, 255, 0.15);
          border-radius: 50%;
          animation: rotateRing 25s linear infinite;
        }
        
        .sound-wave {
          position: absolute;
          border: 2px solid rgba(255, 89, 208, 0.4);
          border-radius: 50%;
          animation: soundWave 2s ease-out infinite;
        }
        
        .frequency-item {
          transition: all 0.2s ease;
        }
        
        .frequency-item:hover {
          background: rgba(255, 255, 255, 0.05);
          transform: translateX(4px);
        }
        
        .play-button {
          transition: all 0.3s ease;
        }
        
        .play-button:hover {
          transform: scale(1.02);
        }
        
        .play-button:active {
          transform: scale(0.98);
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
        width: '600px',
        height: '600px',
        background: 'radial-gradient(circle, rgba(255, 89, 208, 0.12) 0%, rgba(125, 103, 254, 0.08) 30%, transparent 60%)',
        borderRadius: '50%',
        filter: 'blur(60px)',
        animation: 'pulse 10s ease-in-out infinite',
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
          
          <h1 style={{ fontSize: '20px', fontWeight: 700, margin: 0 }}>Your Sound</h1>
          
          <button style={{
            background: 'rgba(255, 255, 255, 0.05)',
            border: 'none',
            borderRadius: '12px',
            padding: '10px',
            cursor: 'pointer',
          }}>
            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="white" strokeWidth="2">
              <path d="M4 12v8a2 2 0 002 2h12a2 2 0 002-2v-8M16 6l-4-4-4 4M12 2v13"/>
            </svg>
          </button>
        </div>

        {/* Main Sound Orb */}
        <div style={{
          display: 'flex',
          flexDirection: 'column',
          alignItems: 'center',
          marginBottom: '32px',
          position: 'relative',
        }}>
          {/* Sound waves when playing */}
          {isPlaying && (
            <>
              <div className="sound-wave" style={{ width: '200px', height: '200px', top: '90px', left: '50%' }} />
              <div className="sound-wave" style={{ width: '200px', height: '200px', top: '90px', left: '50%', animationDelay: '0.5s' }} />
              <div className="sound-wave" style={{ width: '200px', height: '200px', top: '90px', left: '50%', animationDelay: '1s' }} />
            </>
          )}

          <div 
            className="main-orb"
            style={{
              background: 'linear-gradient(135deg, #FF59D0 0%, #7D67FE 40%, #00D4AA 70%, #FAFF0E 100%)',
            }}
          >
            <div className="orb-ring" style={{ inset: '-25px' }} />
            <div className="orb-ring" style={{ inset: '-45px', animationDuration: '35s', animationDirection: 'reverse' }} />
            <div className="orb-ring" style={{ inset: '-65px', animationDuration: '45s' }} />
            
            <div className="orb-inner">
              <div style={{ display: 'flex', gap: '3px', alignItems: 'center' }}>
                {[0.3, 0.5, 0.8, 1, 0.9, 0.7, 1, 0.6, 0.8, 0.4, 0.6].map((h, i) => (
                  <div key={i} style={{
                    width: '5px',
                    height: `${h * 50}px`,
                    background: 'rgba(255,255,255,0.9)',
                    borderRadius: '3px',
                    animation: isPlaying ? `waveform ${0.3 + i * 0.08}s ease-in-out infinite` : 'none',
                    animationDelay: `${i * 0.04}s`,
                  }} />
                ))}
              </div>
            </div>
          </div>

          {/* User Info */}
          <div style={{ textAlign: 'center', marginTop: '24px' }}>
            <h2 style={{
              fontSize: '28px',
              fontWeight: 800,
              margin: '0 0 4px 0',
              background: 'linear-gradient(135deg, #FF59D0 0%, #FAFF0E 100%)',
              WebkitBackgroundClip: 'text',
              WebkitTextFillColor: 'transparent',
            }}>{soundProfile.name}'s Sound</h2>
            <p style={{
              fontSize: '13px',
              color: 'rgba(255,255,255,0.5)',
              margin: '0 0 16px 0',
              fontFamily: "'Space Grotesk', sans-serif",
            }}>{soundProfile.createdFrom}</p>
            
            {/* Quick Stats */}
            <div style={{ display: 'flex', justifyContent: 'center', gap: '12px', flexWrap: 'wrap' }}>
              <div style={{
                background: 'rgba(250, 255, 14, 0.1)',
                border: '1px solid rgba(250, 255, 14, 0.2)',
                borderRadius: '20px',
                padding: '6px 14px',
              }}>
                <span style={{ fontSize: '12px', color: '#FAFF0E', fontWeight: 600 }}>{soundProfile.dominantFrequency}</span>
              </div>
              <div style={{
                background: 'rgba(125, 103, 254, 0.1)',
                border: '1px solid rgba(125, 103, 254, 0.2)',
                borderRadius: '20px',
                padding: '6px 14px',
              }}>
                <span style={{ fontSize: '12px', color: '#7D67FE', fontWeight: 600 }}>{soundProfile.element}</span>
              </div>
              <div style={{
                background: 'rgba(255, 89, 208, 0.1)',
                border: '1px solid rgba(255, 89, 208, 0.2)',
                borderRadius: '20px',
                padding: '6px 14px',
              }}>
                <span style={{ fontSize: '12px', color: '#FF59D0', fontWeight: 600 }}>{soundProfile.sign}</span>
              </div>
            </div>
          </div>
        </div>

        {/* Play Button */}
        <button 
          className="play-button"
          onClick={() => setIsPlaying(!isPlaying)}
          style={{
            width: '100%',
            background: isPlaying 
              ? 'rgba(255, 89, 208, 0.2)' 
              : 'linear-gradient(135deg, #FF59D0 0%, #7D67FE 100%)',
            border: isPlaying ? '2px solid #FF59D0' : 'none',
            borderRadius: '16px',
            padding: '18px',
            fontSize: '16px',
            fontWeight: 700,
            fontFamily: "'Syne', sans-serif",
            color: '#FFFFFF',
            cursor: 'pointer',
            marginBottom: '24px',
            boxShadow: isPlaying ? 'none' : '0 8px 32px rgba(255, 89, 208, 0.3)',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            gap: '12px',
          }}
        >
          {isPlaying ? (
            <>
              <svg width="22" height="22" viewBox="0 0 24 24" fill="currentColor">
                <rect x="6" y="4" width="4" height="16" rx="1"/>
                <rect x="14" y="4" width="4" height="16" rx="1"/>
              </svg>
              Pause Your Sound
            </>
          ) : (
            <>
              <svg width="22" height="22" viewBox="0 0 24 24" fill="currentColor">
                <polygon points="5 3 19 12 5 21 5 3"/>
              </svg>
              Play Your Sound
            </>
          )}
        </button>

        {/* Today's Influence */}
        <div className="glass-card" style={{
          padding: '18px',
          marginBottom: '24px',
          borderLeft: '3px solid #FF59D0',
        }}>
          <div style={{
            display: 'flex',
            justifyContent: 'space-between',
            alignItems: 'flex-start',
            marginBottom: '8px',
          }}>
            <div>
              <p style={{
                fontSize: '11px',
                color: 'rgba(255,255,255,0.5)',
                textTransform: 'uppercase',
                letterSpacing: '1.5px',
                margin: '0 0 4px 0',
              }}>Today's Influence</p>
              <p style={{ fontSize: '14px', fontWeight: 600, margin: 0 }}>{todaysInfluence.transit}</p>
            </div>
            <div style={{
              background: 'rgba(255, 89, 208, 0.15)',
              borderRadius: '12px',
              padding: '4px 10px',
            }}>
              <span style={{ fontSize: '12px', color: '#FF59D0', fontWeight: 600 }}>{todaysInfluence.shift}</span>
            </div>
          </div>
          <p style={{
            fontSize: '13px',
            color: 'rgba(255,255,255,0.6)',
            margin: 0,
            fontFamily: "'Space Grotesk', sans-serif",
            lineHeight: '1.5',
          }}>{todaysInfluence.effect}</p>
        </div>

        {/* Frequency Breakdown */}
        <div style={{ marginBottom: '120px' }}>
          <div style={{
            display: 'flex',
            justifyContent: 'space-between',
            alignItems: 'center',
            marginBottom: '16px',
          }}>
            <h3 style={{ fontSize: '16px', fontWeight: 700, margin: 0 }}>Frequency Breakdown</h3>
            <span style={{ fontSize: '13px', color: '#7D67FE', fontWeight: 600, cursor: 'pointer' }}>Full Chart</span>
          </div>
          
          <div className="glass-card" style={{ padding: '8px' }}>
            {frequencyBreakdown.map((item, index) => (
              <div key={index} className="frequency-item" style={{
                display: 'flex',
                alignItems: 'center',
                gap: '14px',
                padding: '14px',
                borderRadius: '14px',
                cursor: 'pointer',
              }}>
                <div style={{
                  width: '44px',
                  height: '44px',
                  borderRadius: '12px',
                  background: `linear-gradient(135deg, ${item.color}40 0%, ${item.color}20 100%)`,
                  border: `1px solid ${item.color}50`,
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                  flexShrink: 0,
                }}>
                  <span style={{ fontSize: '16px', fontWeight: 700, color: item.color }}>
                    {item.planet === 'Sun' ? '☉' : 
                     item.planet === 'Moon' ? '☽' : 
                     item.planet === 'Rising' ? '↑' :
                     item.planet === 'Mercury' ? '☿' :
                     item.planet === 'Venus' ? '♀' : '♂'}
                  </span>
                </div>
                
                <div style={{ flex: 1, minWidth: 0 }}>
                  <div style={{ display: 'flex', alignItems: 'center', gap: '8px', marginBottom: '2px' }}>
                    <span style={{ fontSize: '14px', fontWeight: 600 }}>{item.planet}</span>
                    <span style={{ fontSize: '12px', color: 'rgba(255,255,255,0.4)' }}>in {item.sign}</span>
                  </div>
                  <p style={{ 
                    fontSize: '11px', 
                    color: 'rgba(255,255,255,0.5)', 
                    margin: 0,
                    fontFamily: "'Space Grotesk', sans-serif",
                  }}>{item.description}</p>
                </div>
                
                <div style={{
                  background: `${item.color}20`,
                  borderRadius: '8px',
                  padding: '6px 10px',
                }}>
                  <span style={{ fontSize: '12px', color: item.color, fontWeight: 600 }}>{item.frequency}</span>
                </div>
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

export default YourSound;
