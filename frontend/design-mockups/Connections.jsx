import React, { useState } from 'react';

const Connections = () => {
  const [activeTab, setActiveTab] = useState('home');
  const [filter, setFilter] = useState('all'); // 'all', 'recent', 'compatible'

  const connections = [
    { 
      id: 1, 
      name: "Maya Chen", 
      sign: "Pisces", 
      color1: "#FF59D0", 
      color2: "#7D67FE", 
      compatibility: 91,
      lastAligned: "2 hours ago",
      status: "online",
      mutualPlanets: ["Moon", "Venus"],
    },
    { 
      id: 2, 
      name: "Jordan Rivera", 
      sign: "Aries", 
      color1: "#FAFF0E", 
      color2: "#FF59D0", 
      compatibility: 78,
      lastAligned: "Yesterday",
      status: "online",
      mutualPlanets: ["Mars", "Sun"],
    },
    { 
      id: 3, 
      name: "Alex Kim", 
      sign: "Scorpio", 
      color1: "#7D67FE", 
      color2: "#00D4AA", 
      compatibility: 87,
      lastAligned: "3 days ago",
      status: "offline",
      mutualPlanets: ["Pluto", "Moon"],
    },
    { 
      id: 4, 
      name: "Sam Taylor", 
      sign: "Leo", 
      color1: "#00D4AA", 
      color2: "#FAFF0E", 
      compatibility: 65,
      lastAligned: "1 week ago",
      status: "offline",
      mutualPlanets: ["Sun"],
    },
    { 
      id: 5, 
      name: "Riley Morgan", 
      sign: "Libra", 
      color1: "#FF8C42", 
      color2: "#FF59D0", 
      compatibility: 82,
      lastAligned: "4 days ago",
      status: "online",
      mutualPlanets: ["Venus", "Mercury"],
    },
  ];

  const pendingRequests = [
    { id: 101, name: "Chris Lee", sign: "Capricorn", color1: "#7D67FE", color2: "#FAFF0E" },
    { id: 102, name: "Pat Johnson", sign: "Gemini", color1: "#FF59D0", color2: "#00D4AA" },
  ];

  const getCompatibilityColor = (score) => {
    if (score >= 85) return '#00D4AA';
    if (score >= 70) return '#FAFF0E';
    if (score >= 50) return '#FF8C42';
    return '#E84855';
  };

  const filteredConnections = [...connections].sort((a, b) => {
    if (filter === 'compatible') return b.compatibility - a.compatibility;
    if (filter === 'recent') {
      const order = ['2 hours ago', 'Yesterday', '3 days ago', '4 days ago', '1 week ago'];
      return order.indexOf(a.lastAligned) - order.indexOf(b.lastAligned);
    }
    return 0;
  });

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
        
        @keyframes pulse {
          0%, 100% { opacity: 0.6; transform: scale(1); }
          50% { opacity: 1; transform: scale(1.05); }
        }
        
        @keyframes float {
          0%, 100% { transform: translateY(0); }
          50% { transform: translateY(-5px); }
        }
        
        .glass-card {
          background: rgba(255, 255, 255, 0.03);
          backdrop-filter: blur(20px);
          -webkit-backdrop-filter: blur(20px);
          border: 1px solid rgba(255, 255, 255, 0.08);
          border-radius: 24px;
        }
        
        .connection-card {
          transition: all 0.2s ease;
        }
        
        .connection-card:hover {
          background: rgba(255, 255, 255, 0.06);
          transform: translateY(-2px);
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
        
        .align-button {
          transition: all 0.2s ease;
        }
        
        .align-button:hover {
          transform: scale(1.05);
        }
        
        .request-card {
          transition: all 0.2s ease;
        }
        
        .request-card:hover {
          background: rgba(255, 255, 255, 0.05);
        }
        
        .nav-item {
          transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
        }
        
        .nav-item:hover {
          transform: translateY(-2px);
        }
        
        .orb-mini {
          animation: float 4s ease-in-out infinite;
        }
      `}</style>

      {/* Background Elements */}
      <div style={{
        position: 'absolute',
        top: '-10%',
        right: '-20%',
        width: '500px',
        height: '500px',
        background: 'radial-gradient(circle, rgba(125, 103, 254, 0.1) 0%, transparent 60%)',
        borderRadius: '50%',
        filter: 'blur(80px)',
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
              <path d="M19 12H5M12 19l-7-7 7-7"/>
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
              <path d="M16 21v-2a4 4 0 00-4-4H5a4 4 0 00-4 4v2M12 11a4 4 0 100-8 4 4 0 000 8zM23 21v-2a4 4 0 00-3-3.87M16 3.13a4 4 0 010 7.75"/>
            </svg>
          </button>
        </div>

        {/* Search Bar */}
        <div style={{
          background: 'rgba(255, 255, 255, 0.05)',
          border: '1px solid rgba(255, 255, 255, 0.08)',
          borderRadius: '16px',
          padding: '14px 18px',
          display: 'flex',
          alignItems: 'center',
          gap: '12px',
          marginBottom: '20px',
        }}>
          <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="rgba(255,255,255,0.4)" strokeWidth="2">
            <circle cx="11" cy="11" r="8"/>
            <path d="M21 21l-4.35-4.35"/>
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
          marginBottom: '24px',
          overflowX: 'auto',
          paddingBottom: '4px',
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

        {/* Pending Requests */}
        {pendingRequests.length > 0 && (
          <div style={{ marginBottom: '24px' }}>
            <div style={{
              display: 'flex',
              justifyContent: 'space-between',
              alignItems: 'center',
              marginBottom: '12px',
            }}>
              <h3 style={{ fontSize: '14px', fontWeight: 600, margin: 0, color: 'rgba(255,255,255,0.7)' }}>
                Pending Requests
                <span style={{
                  marginLeft: '8px',
                  background: '#FF59D0',
                  color: '#0A0A0F',
                  fontSize: '11px',
                  fontWeight: 700,
                  padding: '2px 8px',
                  borderRadius: '10px',
                }}>{pendingRequests.length}</span>
              </h3>
            </div>
            
            <div style={{ display: 'flex', gap: '12px', overflowX: 'auto', paddingBottom: '8px' }}>
              {pendingRequests.map((request) => (
                <div key={request.id} className="request-card glass-card" style={{
                  padding: '16px',
                  minWidth: '160px',
                  textAlign: 'center',
                }}>
                  <div className="orb-mini" style={{
                    width: '56px',
                    height: '56px',
                    borderRadius: '50%',
                    background: `linear-gradient(135deg, ${request.color1} 0%, ${request.color2} 100%)`,
                    margin: '0 auto 12px',
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'center',
                    fontSize: '22px',
                    fontWeight: 700,
                  }}>{request.name[0]}</div>
                  <p style={{ fontSize: '14px', fontWeight: 600, margin: '0 0 4px 0' }}>{request.name}</p>
                  <p style={{ fontSize: '11px', color: 'rgba(255,255,255,0.5)', margin: '0 0 12px 0' }}>{request.sign}</p>
                  <div style={{ display: 'flex', gap: '8px' }}>
                    <button style={{
                      flex: 1,
                      background: 'rgba(255, 255, 255, 0.1)',
                      border: 'none',
                      borderRadius: '10px',
                      padding: '8px',
                      cursor: 'pointer',
                    }}>
                      <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="rgba(255,255,255,0.6)" strokeWidth="2">
                        <path d="M18 6L6 18M6 6l12 12"/>
                      </svg>
                    </button>
                    <button style={{
                      flex: 1,
                      background: 'linear-gradient(135deg, #00D4AA 0%, #00B894 100%)',
                      border: 'none',
                      borderRadius: '10px',
                      padding: '8px',
                      cursor: 'pointer',
                    }}>
                      <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="white" strokeWidth="2">
                        <polyline points="20 6 9 17 4 12"/>
                      </svg>
                    </button>
                  </div>
                </div>
              ))}
            </div>
          </div>
        )}

        {/* Connections List */}
        <div style={{ marginBottom: '120px' }}>
          <h3 style={{ 
            fontSize: '14px', 
            fontWeight: 600, 
            margin: '0 0 12px 0', 
            color: 'rgba(255,255,255,0.7)' 
          }}>
            Your Cosmic Circle ({connections.length})
          </h3>
          
          <div style={{ display: 'flex', flexDirection: 'column', gap: '12px' }}>
            {filteredConnections.map((connection) => (
              <div key={connection.id} className="connection-card glass-card" style={{
                padding: '18px',
                display: 'flex',
                alignItems: 'center',
                gap: '16px',
                cursor: 'pointer',
              }}>
                {/* Avatar Orb */}
                <div style={{ position: 'relative' }}>
                  <div className="orb-mini" style={{
                    width: '56px',
                    height: '56px',
                    borderRadius: '50%',
                    background: `linear-gradient(135deg, ${connection.color1} 0%, ${connection.color2} 100%)`,
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'center',
                    fontSize: '20px',
                    fontWeight: 700,
                  }}>{connection.name.split(' ').map(n => n[0]).join('')}</div>
                  {/* Online indicator */}
                  {connection.status === 'online' && (
                    <div style={{
                      position: 'absolute',
                      bottom: '2px',
                      right: '2px',
                      width: '14px',
                      height: '14px',
                      borderRadius: '50%',
                      background: '#00D4AA',
                      border: '3px solid #0D0D15',
                    }} />
                  )}
                </div>

                {/* Info */}
                <div style={{ flex: 1, minWidth: 0 }}>
                  <div style={{ display: 'flex', alignItems: 'center', gap: '8px', marginBottom: '4px' }}>
                    <h4 style={{ fontSize: '15px', fontWeight: 600, margin: 0 }}>{connection.name}</h4>
                    <span style={{ 
                      fontSize: '11px', 
                      color: 'rgba(255,255,255,0.4)',
                      background: 'rgba(255,255,255,0.05)',
                      padding: '2px 8px',
                      borderRadius: '10px',
                    }}>{connection.sign}</span>
                  </div>
                  
                  <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
                    <div style={{ display: 'flex', alignItems: 'center', gap: '4px' }}>
                      <div style={{
                        width: '8px',
                        height: '8px',
                        borderRadius: '50%',
                        background: getCompatibilityColor(connection.compatibility),
                      }} />
                      <span style={{ 
                        fontSize: '12px', 
                        color: getCompatibilityColor(connection.compatibility),
                        fontWeight: 600,
                      }}>{connection.compatibility}%</span>
                    </div>
                    <span style={{ fontSize: '11px', color: 'rgba(255,255,255,0.4)' }}>
                      Aligned {connection.lastAligned}
                    </span>
                  </div>
                  
                  {/* Mutual Planets */}
                  <div style={{ display: 'flex', gap: '6px', marginTop: '8px' }}>
                    {connection.mutualPlanets.map((planet, i) => (
                      <span key={i} style={{
                        fontSize: '10px',
                        color: 'rgba(255,255,255,0.5)',
                        background: 'rgba(255,255,255,0.05)',
                        padding: '3px 8px',
                        borderRadius: '8px',
                      }}>
                        {planet === 'Moon' ? '☽' : planet === 'Sun' ? '☉' : planet === 'Venus' ? '♀' : planet === 'Mars' ? '♂' : planet === 'Mercury' ? '☿' : '♇'} {planet}
                      </span>
                    ))}
                  </div>
                </div>

                {/* Align Button */}
                <button className="align-button" style={{
                  background: 'linear-gradient(135deg, #7D67FE 0%, #FF59D0 100%)',
                  border: 'none',
                  borderRadius: '12px',
                  padding: '12px 16px',
                  cursor: 'pointer',
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                  boxShadow: '0 4px 16px rgba(125, 103, 254, 0.3)',
                }}>
                  <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="white" strokeWidth="2">
                    <circle cx="12" cy="12" r="10"/>
                    <path d="M12 6v6l4 2"/>
                  </svg>
                </button>
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

export default Connections;
